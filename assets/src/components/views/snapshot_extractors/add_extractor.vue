<template>
  <div>
  <div class="add-modal" @click="showExModalEvent()"><button class="btn btn-secondary mb-1" type="button"><i class="fa fa-plus"></i> Add Extractor</button></div>
  <div v-if="showExModal">
    <transition name="modal">
      <div class="modal modal-mask" style="display: block">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Extractor</h4>
            </div>
            <div class="modal-body">
              <form>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Construction Camera</label>
                  <div class="col-sm-8">
                    <cool-select
                      v-model="selected"
                      :items="items"
                      :loading="loading"
                      item-text="name"
                      placeholder="Enter Camera name"
                      :event-emitter="selectEventEmitter"
                      :reset-search-on-blur="true"
                      disable-filtering-by-search
                      @search="onSearch"
                    >
                      <template slot="no-data">
                        {{
                          noData
                            ? "No information found by request."
                            : "We need at least 2 letters to search."
                        }}
                      </template>
                      <template slot="item" slot-scope="{ item }">
                        <div class="item">
                          <img :src="item.thumbnail" class="logo" />
                          <div>
                            <span class="item-name"> {{ item.name }} </span> <br />
                          </div>
                        </div>
                      </template>
                    </cool-select>
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">From DateTime</label>
                  <div class="col-sm-8">
                    <date-picker v-model="fromDateTime" ref="datepicker1" type="datetime" lang="en" :format="dateFormat" confirm value-type="format" @confirm="setFromDate" @clear="clearFromDate"></date-picker>
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">To DateTime</label>
                  <div class="col-sm-8">
                    <date-picker v-model="toDateTime" ref="datepicker2" type="datetime" lang="en" :format="dateFormat" confirm value-type="format" @confirm="setToDate" @clear="clearToDate"></date-picker>
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Interval</label>
                  <div class="col-sm-8">
                    <select name="Interval" v-model="interval" class="form-control">
                      <option value="">Select Interval</option>
                      <option value="0">All</option>
                      <option value="5">1 Frame Every 5 seconds</option>
                      <option value="10">1 Frame Every 10 seconds</option>
                      <option value="15">1 Frame Every 15 seconds</option>
                      <option value="20">1 Frame Every 20 seconds</option>
                      <option value="30">1 Frame Every 30 seconds</option>
                      <option value="60">1 Frame Every 1 min</option>
                      <option value="300">1 Frame Every 5 min</option>
                      <option value="600">1 Frame Every 10 min</option>
                      <option value="900">1 Frame Every 15 min</option>
                      <option value="1200">1 Frame Every 20 min</option>
                      <option value="1800">1 Frame Every 30 min</option>
                      <option value="3600">1 Frame Every hour</option>
                      <option value="7200">1 Frame Every 2 hours</option>
                      <option value="21600">1 Frame Every 6 hours</option>
                      <option value="43200">1 Frame Every 12 hours</option>
                      <option value="86400">1 Frame Every 24 hours</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Extraction</label>
                  <div class="col-sm-8">
                    <select name="Interval" v-model="extraction" class="form-control">
                      <option value="cloud">Cloud</option>
                      <option value="local">Local</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row" v-show="showLocalOptions">
                  <label class="col-sm-4 col-form-label">Jpegs to Dropbox</label>
                  <div class="col-sm-8">
                    <select name="Interval" v-model="jpegs_to_dropbox" class="form-control">
                      <option value="true">True</option>
                      <option value="false">false</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row" v-show="showLocalOptions">
                  <label class="col-sm-4 col-form-label">MP4 to Dropbox</label>
                  <div class="col-sm-8">
                    <select name="Interval" v-model="create_mp4" class="form-control">
                      <option value="true">True</option>
                      <option value="false">False</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row" v-show="showLocalOptions">
                  <label class="col-sm-4 col-form-label">Sync to Cloud Recordings</label>
                  <div class="col-sm-8">
                    <select name="Interval" v-model="inject_to_cr" class="form-control">
                      <option value="true">True</option>
                      <option value="false">False</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Schedule</label>
                  <div class="col-sm-8">
                    <select v-model="schedule_type" class="form-control" v-on:change="handleChange">
                      <option value="continuous">Continuous</option>
                      <option value="working_hours">Working Hours</option>
                      <option value="on_schedule">On Schedule</option>
                    </select>
                  </div>
                </div>
                <div class="form-group row" v-show="showSchedule">
                  <div class="col-sm-12">
                    <full-calendar
                    :config="config"
                    @event-created="eventCreated"
                    @event-selected="eventSelected"
                    @event-resize="eventResized"
                    ref="calendar"
                    class="full-calendar">
                    </full-calendar>
                  </div>
                </div>
              </form>
              <p v-if="errors.length">
                <b>Please correct the following error(s):</b>
                <ul>
                  <li v-for="error in errors">{{ error }}</li>
                </ul>
              </p>
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" type="button" @click="validateFormAndSave($event)">Save</button>
              <button class="btn btn-secondary" type="button" @click="clearForm()">Close</button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
  </div>
</template>

<style scoped>

.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.add-modal {
  float: right;
  margin-top: -35px;
  margin-right: 51px;
}

.modal-dialog {
  width: 560px;
  max-width: 610px;
  margin-top: 114.5px;
}

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


.item {
  display: flex;
  align-items: center;
}

.item-name {
  font-size: 18px;
}
.item-domain {
  color: grey;
}

.logo {
  max-width: 60px;
  margin-right: 10px;
  border: 1px solid #eaecf0;
}


.full-calendar .fc-axis {
  width: 36px;
  min-width: 36px;
}

.full-calendar .fc-ltr .fc-axis {
  min-width: 36px;
}


</style>

<script>
import { FullCalendar } from 'vue-full-calendar';
import { CoolSelect, EventEmitter } from "vue-cool-select";
import DatePicker from 'vue2-datepicker';
import jQuery from 'jquery';
import moment from "moment";

  export default {
    components: {
      CoolSelect, DatePicker, FullCalendar
    },
    data: () => {
      return {
        selectEventEmitter: new EventEmitter(),
        events: null,
        showExModal: false,
        jpegs_to_dropbox: true,
        create_mp4: false,
        inject_to_cr: false,
        cameras: [],
        errors: [],
        search: "",
        camera: "",
        selected: null,
        showSchedule: false,
        showLocalOptions: false,
        items: [],
        loading: false,
        timeoutId: null,
        noData: false,
        fromDateTime: "",
        toDateTime: "",
        interval: "600",
        extraction: "cloud",
        schedule_type: "working_hours",
        schedule: JSON.stringify({
          "Monday": ["08:00-18:00"],
          "Tuesday": ["08:00-18:00"],
          "Wednesday": ["08:00-18:00"],
          "Thursday": ["08:00-18:00"],
          "Friday": ["08:00-18:00"],
          "Saturday": [],
          "Sunday": []
        }),
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
          header: false,
          handleWindowResize: true,
          windowResizeDelay: 20
        },
        dateFormat: {
          stringify: (date) => {
            return date ? moment(date).format("YYYY-MM-DD HH:mm:ss") : null
          },
          parse: (value) => {
            return value ? moment(value, 'YYYY-MM-DD HH:mm:ss').toDate() : null
          }
        }
      }
    },

    watch: {
      schedule_type(newVal, oldVal) {
        if (newVal == "on_schedule") {
          this.$nextTick(() => {
            this.showSchedule = true
          });
        } else {
          this.showSchedule = false
        }
      },

      extraction(newVal, oldVal) {
        if (newVal == "local") {
          this.$nextTick(() => {
            this.showLocalOptions = true
          });
        } else {
          this.showLocalOptions = false
        }
      }
    },

    methods: {

      showExModalEvent() {
        console.log("works")
        this.showExModal = true
      },

      clearFromDate() {
        this.fromDateTime = ""
      },

      clearToDate() {
        this.toDateTime = ""
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
        if (this.schedule_type === "continuous"){
          let schedule = {
            "Monday": ["00:00-23:59"],
            "Tuesday": ["00:00-23:59"],
            "Wednesday": ["00:00-23:59"],
            "Thursday": ["00:00-23:59"],
            "Friday": ["00:00-23:59"],
            "Saturday": ["00:00-23:59"],
            "Sunday": ["00:00-23:59"]
          }
          this.schedule = JSON.stringify(schedule);
          this.config.events = null
          this.config.eventSources = null
          this.clearAllEvents()
        } else if (this.schedule_type === "working_hours"){
          let schedule = {
            "Monday": ["08:00-18:00"],
            "Tuesday": ["08:00-18:00"],
            "Wednesday": ["08:00-18:00"],
            "Thursday": ["08:00-18:00"],
            "Friday": ["08:00-18:00"],
            "Saturday": [],
            "Sunday": []
          }
          this.schedule = JSON.stringify(schedule);
          this.config.events = null
          this.config.eventSources = null
          this.clearAllEvents()
        }
        console.log(this.schedule);
      },

      clearAllEvents() {
        var events = this.$refs.calendar.fireMethod('clientEvents');
        events.preventDefault
        for (var i = 0; i < events.length; i++) {
          this.$refs.calendar.fireMethod('removeEvents', events[i]._id);
        }
      },

      setFromDate(val) {
        console.log(val)
        this.fromDateTime =  val
      },

      setToDate(val) {
        console.log(val)
        this.toDateTime =  val
      },

      async onSearch(search) {
        const lettersLimit = 2;

        this.noData = false;
        if (search.length < lettersLimit) {
          this.items = [];
          this.loading = false;
          return;
        }
        this.loading = true;

        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(async () => {
          const response = await fetch(
            `/v1/construction_cameras?search=${search}`
          );

          console.log(response)
          this.items = await response.json();
          this.loading = false;

          if (!this.items.length) this.noData = true;

        }, 500);
      },

      validateFormAndSave (e) {
        e.preventDefault()
        if (this.schedule_type == "on_schedule") {
          this.schedule = JSON.stringify(this.parseCalendar())
        }
        this.errors = []

        if (this.fromDateTime == "") {
          this.errors.push("From DateTime cannot be empty.")
        }

        if (this.toDateTime == "") {
          this.errors.push("To DateTime cannot be empty.")
        }

        if (this.selected == null) {
          this.errors.push("Please at least select a Camera.")
        }

        if (Object.keys(this.errors).length === 0) {

          if (this.extraction == "cloud") {
            let params = {
              camera_id: this.selected.camera_id,
              from_date: this.fromDateTime,
              to_date: this.toDateTime,
              schedule: this.schedule,
              interval: this.interval,
              requestor: this.$root.user.email
            }
            this.$http.post("/v1/snapshot_extractors", {...params}).then(response => {

              this.$notify({
                group: "admins",
                title: "Info",
                type: "success",
                text: "Snapshot Extractor has been added (Cloud)!",
              });

              this.$events.fire('se-added', {})
              this.clearForm()
            }, error => {
              this.$notify({
                group: "admins",
                title: "Error",
                type: "error",
                text: "Something went wrong!",
              });
            });
          } else {
            let params = {
              start_date: moment(this.fromDateTime).format(),
              end_date: moment(this.toDateTime).format(),
              schedule: this.schedule,
              interval: this.interval,
              create_mp4: this.create_mp4,
              inject_to_cr: this.inject_to_cr,
              jpegs_to_dropbox: this.jpegs_to_dropbox,
              requester: this.$root.user.email,
              api_key: this.selected.api_key,
              api_id: this.selected.api_id
            }
            this.$http.post(`${this.$root.api_url}/v2/cameras/${this.selected.exid}/nvr/snapshots/extract`, {...params}).then(response => {

              this.$notify({
                group: "admins",
                title: "Info",
                type: "success",
                text: "Snapshot Extractor has been added (Local)!",
              });

              this.$events.fire('se-added', {})
              this.clearForm()
            }, error => {
              this.$notify({
                group: "admins",
                title: "Error",
                type: "error",
                text: "Something went wrong!",
              });
            });
          }
        }
      },
      clearForm () {
        this.errors = [];
        this.cameras = [];
        this.selected = null;
        this.clearAllEvents();
        this.showSchedule = false;
        this.items = [];
        this.loading = false;
        this.timeoutId = null;
        this.noData = false;
        this.fromDateTime = "";
        this.toDateTime = "";
        this.interval = "600";
        this.extraction = "cloud";
        this.schedule_type = "working_hours";
        this.jpegs_to_dropbox = true;
        this.showLocalOptions = false;
        this.create_mp4 = false;
        this.inject_to_cr = false;
        this.schedule = JSON.stringify({
          "Monday": ["08:00-18:00"],
          "Tuesday": ["08:00-18:00"],
          "Wednesday": ["08:00-18:00"],
          "Thursday": ["08:00-18:00"],
          "Friday": ["08:00-18:00"],
          "Saturday": [],
          "Sunday": []
        });
        this.selectEventEmitter.emit("set-search", "");
        this.showExModal = false;
      },

      parseCalendar: function() {
        let events = this.$refs.calendar.fireMethod('clientEvents');
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
        return schedule
      }
    }
  }
</script>