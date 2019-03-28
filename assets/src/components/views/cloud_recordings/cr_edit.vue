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
                <div id="calendar"></div>
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
import moment from "moment";
import axios from "axios";

import { Calendar } from '@fullcalendar/core';
import interactionPlugin from '@fullcalendar/interaction';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import momentPlugin from '@fullcalendar/moment';


  export default {
    props: ["crSettings", "showCRModal"],
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
        calendar: null,
        config: {
          plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, momentPlugin],
          axisFormat: 'HH',
          defaultView: 'timeGridWeek',
          allDaySlot: false,
          slotDuration: '00:60:00',
          columnFormat: 'dddd',
          columnHeaderFormat: { weekday: 'short' },
          defaultDate: '1970-01-01',
          dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
          eventLimit: true,
          eventOverlap: false,
          eventColor: '#458CC7',
          firstDay: 1,
          height: 'auto',
          selectHelper: true,
          selectable: true,
          timezone: 'UTC',
          header: {
            left: '',
            center: '',
            right: '',
          },
          header: false,
          editable: true,
          events: null
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
        if (this.status === "on-scheduled") {
          this.showCalendar = true
        }
      }
    },

    updated() {
      if (this.status === "on-scheduled") {

        if (this.calendar == null) {
          console.log(this.schedule)
          let calendarEl = document.getElementById('calendar');

          let calendarConfig = this.config

          let select = (event) => {
            this.selectCalendar(event)
          }

          let eventClick = (event) => {
            this.clickCalendar(event)
          }

          let eventDrop = (event) => {
            this.dropCalendar(event)
          }

          let eventResize = (event) => {
            this.resizeCalendar(event)
          }

          calendarConfig.select = select;
          calendarConfig.eventClick = eventClick;
          calendarConfig.eventDrop = eventDrop;
          calendarConfig.eventResize = eventResize;

          this.calendar = new Calendar(calendarEl, calendarConfig);
          this.calendar.render();

          this.renderEvents()
        }
      } else {
        this.destroyCalendar()
      }
    },

    methods: {

      renderEvents() {
        let schedule = JSON.parse(this.schedule)
        let calendarWeek = this.currentCalendarWeek()
        let days = Object.keys(schedule)

        days.forEach((weekDay) => {
          let day  = schedule[weekDay]
          if (day.length != 0) {
            day.forEach((event) => {
              let start = event.split("-")[0]
              let end = event.split("-")[1]

              let addEvent = {
                id: this.generate_random_string(4),
                start: moment(`${calendarWeek[weekDay]} ${start}`, "YYYY-MM-DD HH:mm")._i,
                end: moment(`${calendarWeek[weekDay]} ${end}`, "YYYY-MM-DD HH:mm")._i
              }
              this.calendar.addEvent(addEvent);
            });
          }
        });
      },

      generate_random_string(string_length) {
        let random_string = '';
        let random_ascii;
        for(let i = 0; i < string_length; i++) {
            random_ascii = Math.floor((Math.random() * 25) + 97);
            random_string += String.fromCharCode(random_ascii)
        }
        return random_string
      },

      currentCalendarWeek() {
        let calendarWeek = {}
        let weekStart = moment(this.calendar.view.currentStart)
        let weekEnd = moment(this.calendar.view.currentEnd)
        while (weekStart.isBefore(weekEnd)) {
          let weekDay = weekStart.format("dddd")
          calendarWeek[weekDay] = weekStart.format('YYYY-MM-DD')
          weekStart.add(1, "days")
        }
        return calendarWeek;
      },

      selectCalendar(event) {
        this.calendar.addEvent(event)
        this.schedule = JSON.stringify(this.parseCalendar())
      },

      clickCalendar(event) {
        if (window.confirm("Are you sure you want to delete this event?")) {
          let findingID = null
          if (event.event.id === "") {
            findingID = event.el
          } else {
            findingID = event.event.id
          }
          let removeEvent = this.calendar.getEventById( findingID )
          removeEvent.remove()
        }
        this.schedule = JSON.stringify(this.parseCalendar())
      },

      dropCalendar(event) {
        this.schedule = JSON.stringify(this.parseCalendar())
      },

      resizeCalendar(event) {
        this.schedule = JSON.stringify(this.parseCalendar())
      },

      destroyCalendar() {
        if (this.calendar != null) {
          this.calendar.destroy();
          this.calendar = null
        }
      },

      SaveCR() {
        if (this.status == "on-scheduled") {
          this.schedule = JSON.stringify(this.parseCalendar())
        }

        this.ajaxWait = true

        let params = {
          status: this.status,
          storage_duration: this.storage_duration,
          frequency: this.interval,
          schedule: this.schedule,
          api_key: this.api_key,
          api_id: this.api_id
        }

        this.$http.post(`https://media.evercam.io/v2/cameras/${this.exid}/apps/cloud-recording`, {...params}).then(response => {

          this.$notify({
            group: "admins",
            title: "Info",
            type: "success",
            text: "Cloud Recordings has been updated!",
          });

          this.ajaxWait = false
          // clear all evenrts here
          this.showCalendar = false;
          this.$events.fire("close-cr-modal", false);
          this.$events.fire("refresh-cr-table", true);

        }, error => {
          console.log(error)
          this.ajaxWait = false
          this.$notify({
            group: "admins",
            title: "Info",
            type: "error",
            text: `${error.statusText}`
          });
        });
      },

      updateSchedule() {
        var schedule = JSON.stringify(this.parseCalendar());
        this.schedule = schedule
        console.log(this.schedule);
      },

      handleChange() {
        if (this.status === "on" || this.status === "off" ){
          this.showCalendar = false;
          this.destroyCalendar();
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

        } else if (this.status === "on-scheduled"){
          this.showCalendar = true

        } else if (this.status === "paused") {
          this.showCalendar = false;
          this.destroyCalendar();
        }
      },

      hideCRModal () {
        this.showCalendar = false;
        this.destroyCalendar();
        this.$events.fire("close-cr-modal", false);
      },

      parseCalendar () {
        let events = this.calendar.getEvents()
        let schedule = {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        }
        events.map(function(event){
          let startTime = `${moment(event.start).format('HH')}:${moment(event.start).format('mm')}`
          let endTime = `${moment(event.end).format('HH')}:${moment(event.end).format('mm')}`
          let day = moment(event.start).format('dddd')
          schedule[day] = schedule[day].concat(`${startTime}-${endTime}`)
        });
        return schedule;
      }
    }
  }
</script>