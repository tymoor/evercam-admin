<template>
  <div v-if="showCRModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h3 class="modal-title">
              Cloud Recordings
            </h3>
          </div>
          <div class="modal-body">
            <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
            <form>
              <div class="form-group">
                <label>Status:</label>
                <select id="cloud-recording-status" @change="handleChange()" class="form-control" v-model="status">
                  <option value="on">On</option>
                  <option value="on-scheduled">On Scheduled</option>
                  <option value="off">Off</option>
                  <option value="paused">Paused</option>
                </select>
              </div>

              <div class="form-group">
                <label>Storage Duration:</label>
                <select id="cloud-recording-duration" class="form-control" v-model="storage_duration">
                  <option value="1">24 hours recording</option>
                  <option value="7">7 days recording</option>
                  <option value="30">30 days recording</option>
                  <option value="90">90 days recording</option>
                  <option value="-1">Infinity</option>
                </select>
              </div>

              <div class="form-group">
                <label>Frequency:</label>
                <select id="cloud-recording-frequency" class="form-control" v-model="interval">
                  <option value="60">60 (1 per second)</option>
                  <option value="30">30 (1 every 2 seconds)</option>
                  <option value="12">12 (1 every 5 seconds)</option>
                  <option value="6">6 (1 every 10 seconds)</option>
                  <option value="1">1 (1 every 60 seconds)</option>
                  <option value="5">1 (1 every 5 minutes)</option>
                  <option value="10">1 (1 every 10 minutes)</option>
                </select>
              </div>


              <div class="form-group" v-show="showCalendar">
                <label>Schedule:</label>
                <full-calendar
                :config="config"
                @event-created="eventCreated"
                @event-selected="eventSelected"
                @event-resize="eventResized"
                ref="calendar">
                </full-calendar>
              </div>

            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" @click="SaveCR()"> Save </button>
            <button type="button" class="btn btn-primary" @click="hideCRModal()"> Close </button>
          </div>
        </div>
      </div>
    </div>
    </transition>
  </div>
</template>

<style scoped>
.modal-mask {
   position: fixed;
   z-index: 9998;
   top: 0;
   left: 0;
   width: 100%;
   height: 100%;
   background-color: rgba(0, 0, 0, .5);
   display: table;
   overflow: auto;
   transition: opacity .3s ease;
}

.modal-dialog {
  width: 550px;
  max-width: 100%;
}

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
import { FullCalendar } from 'vue-full-calendar';
import moment from "moment";
import axios from "axios";

  export default {
    props: ["crSettings", "showCRModal"],
    components: {
      FullCalendar
    },
    data: () => {
      return {
        showCalendar: false,
        status: "",
        storage_duration: 0,
        interval: 0,
        schedule: null,
        api_key: "",
        api_id: "",
        exid: "",
        ajaxWait: false,
        config: {
          axisFormat: 'HH',
          defaultView: 'agendaWeek',
          allDaySlot: false,
          slotDuration: '00:60:00',
          columnFormat: 'ddd',
          defaultDate: '1970-01-01',
          dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
          eventLimit: true,
          eventOverlap: false,
          eventColor: '#458CC7',
          firstDay: 1,
          height: 'auto',
          selectHelper: true,
          selectable: true,
          timezone: 'local',
          header: {
            left: '',
            center: '',
            right: '',
          },
          header:false
        }
      }
    },

    watch: {
      crSettings() {
        this.status = this.crSettings.status,
        this.storage_duration = this.crSettings.storage_duration,
        this.interval = this.crSettings.interval,
        this.schedule = JSON.stringify(this.crSettings.schedule_for_edit),
        this.api_id = this.crSettings.api_id,
        this.api_key = this.crSettings.api_key,
        this.exid = this.crSettings.exid
      }
    },

    methods: {

      SaveCR() {
        if (this.status == "on-scheduled") {
          this.schedule = JSON.stringify(this.parseCalendar())
        }
        this.ajaxWait = true
        axios.post(`${this.$root.api_url}/v2/cameras/${this.exid}/apps/cloud-recording`, {
          params: {
            status: this.status,
            storage_duration: this.storage_duration,
            frequency: this.interval,
            schedule: this.schedule,
            api_key: this.api_key,
            api_id: this.api_id
          }
        }).then(response => {
          this.ajaxWait = false

          this.$notify({
            group: "admins",
            title: "Info",
            type: "success",
            text: "Cloud Recordings has been updated!"
          });

          this.$events.fire("close-cr-modal", false)
        }).catch(error => {
          console.log(error.response)
          this.ajaxWait = false
          this.$notify({
            group: "admins",
            title: "Info",
            type: "error",
            text: `${error.response.request.responseText}`
          });

        });
      },

      clearAllEvents() {
        var events = this.$refs.calendar.fireMethod('clientEvents');
        events.preventDefault
        for (var i = 0; i < events.length; i++) {
          this.$refs.calendar.fireMethod('removeEvents', events[i]._id);
        }
      },

      eventResized(event) {
        this.$refs.calendar.$emit('refetch-events');
        this.updateSchedule()
      },

      eventSelected(event, jsEvent, view) {
        console.log(event);
        event.preventDefault
        if (window.confirm("Are you sure you want to delete this event?")){
          this.$refs.calendar.fireMethod('removeEvents', event._id);
        }
        this.updateSchedule()
      },

      eventCreated(start_end) {
        let eventData;
        eventData = {
          start: start_end.start,
          end: start_end.end
        }
        this.$refs.calendar.fireMethod('renderEvent', eventData, true);
        this.$refs.calendar.fireMethod('unselect');
        this.updateSchedule()
      },

      updateSchedule() {
        var schedule = JSON.stringify(this.parseCalendar());
        this.schedule = schedule
        console.log(this.schedule);
      },

      handleChange() {
        if (this.status === "on" || this.status === "off" ){
          this.showCalendar = false;
          let schedule = {
            "Monday": ["00:00-23:59"],
            "Tuesday": ["00:00-23:59"],
            "Wednesday": ["00:00-23:59"],
            "Thursday": ["00:00-23:59"],
            "Friday": ["00:00-23:59"],
            "Saturday": ["00:00-23:59"],
            "Sunday": ["00:00-23:59"]
          };
          this.schedule = JSON.stringify(schedule);
          this.config.events = null
          this.config.eventSources = null
          this.clearAllEvents()
        } else if (this.status === "on-scheduled"){
          this.showCalendar = true
          this.config.events = null
          this.config.eventSources = null
          this.clearAllEvents()
        } else if (this.status === "paused") {
          this.showCalendar = false;
          console.log(this.schedule);
        }
        console.log(this.schedule);
      },

      hideCRModal () {
        this.showCalendar = false;
        this.clearAllEvents()
        this.$events.fire("close-cr-modal", false);
      },

      parseCalendar: function() {
        var events = this.$refs.calendar.fireMethod('clientEvents');
        var schedule = {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        }
        events.map(function(event){
          var endTime = ''
          var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
          var startTime = moment(event.start).get('hours');
          var endTime = moment(event.end).get('hours');
          var day = moment(event.start).get('day');
          schedule[days[day]] = schedule[days[day]].concat(startTime + "-" + endTime)
        });
        return schedule
      }
    }
  }
</script>