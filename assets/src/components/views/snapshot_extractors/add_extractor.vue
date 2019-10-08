<template>
  <div>
  <div class="add-modal" @click="showExModalEvent()"><button class="btn btn-secondary mb-1" type="button"><i class="fa fa-plus"></i> Create Extraction</button></div>
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
                  <label class="col-sm-4 col-form-label">Account</label>
                  <div class="col-sm-8">
                    <select name="Account" v-model="account" class="form-control">
                      <option value="-1">Construction + Old Construction</option>
                      <option value="116066">Smart Cities</option>
                      <option value="7011">Garda Shared</option>
                      <option v-bind:value="this.$root.user.user_id">{{ this.$root.user.firstname }} {{ this.$root.user.lastname }}</option>
                    </select>
                  </div>
                </div>
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
                <div class="form-group row">
                  <div id="calendar"></div>
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

#calendar {
  margin: 0 auto;
  width: 95%;
}
</style>

<script>
import { CoolSelect, EventEmitter } from "vue-cool-select";
import DatePicker from 'vue2-datepicker';
import moment from "moment";

import { Calendar } from '@fullcalendar/core';
import interactionPlugin from '@fullcalendar/interaction';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import momentPlugin from '@fullcalendar/moment';

  export default {
    components: {
      CoolSelect, DatePicker
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
        showSchedule: true,
        showLocalOptions: false,
        items: [],
        loading: false,
        timeoutId: null,
        noData: false,
        fromDateTime: "",
        toDateTime: "",
        interval: "600",
        account: "-1",
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


    updated() {
      if (this.schedule_type === "on_schedule" || this.schedule_type === "working_hours" || this.schedule_type === "continuous") {

        this.destroyCalendar();
        if (this.calendar === null) {
          let calendarEl = document.getElementById('calendar');
          if (calendarEl) {

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

            this.clearCalendar();
            if (this.schedule_type === "on_schedule") {
              // dont render any event
            } else {
              this.renderEvents()
            }
          }
        }
      } else {
        console.log("detosyred")
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

      showExModalEvent() {
        this.showExModal = true
      },

      clearFromDate() {
        this.fromDateTime = ""
      },

      clearToDate() {
        this.toDateTime = ""
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
          this.clearCalendar();
          this.showSchedule = true
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
          this.clearCalendar();
          this.showSchedule = true
        } else if (this.schedule_type === "on_schedule") {
          this.clearCalendar();
          this.showSchedule = true
        }
      },

      setFromDate(val) {
        this.fromDateTime =  val
      },

      setToDate(val) {
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
            `/v1/extraction_cameras?search=${search}&account=${this.account}`
          );

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

        if (moment(this.fromDateTime).unix() > moment(this.toDateTime).unix()) {
          this.errors.push("From Date cannot be greater than To Date.") 
        }

        if (Object.keys(this.errors).length === 0) {

          if (this.extraction == "cloud") {
            let params = {
              camera_id: this.selected.camera_id,
              from_date: this.fromDateTime,
              to_date: this.toDateTime,
              schedule: this.schedule,
              interval: this.interval,
              requestor: this.$root.user.email,
              api_key: this.selected.api_key,
              api_id: this.selected.api_id
            }

            axios({
              method: 'post',
              url: `${this.$root.api_url}/v2/cameras/${this.selected.exid}/apps/cloud-extractions`,
              data: {
                camera_id: this.selected.camera_id,
                from_date: this.fromDateTime,
                to_date: this.toDateTime,
                schedule: this.schedule,
                interval: this.interval,
                requestor: this.$root.user.email,
                api_key: this.selected.api_key,
                api_id: this.selected.api_id
              }
            }).then(response => {
              if (response.status == 200) {
                this.showSuccessMsg({
                  title: "Success",
                  message: "Snapshot Extractor has been added (Cloud)!"
                });

                this.$events.fire('se-added', {})
                this.clearForm()
              } else {
                this.showErrorMsg({
                  title: "Error",
                  message: "Something went wrong!"
                })
              }
            })
          } else {

            axios({
              method: 'post',
              url: `${this.$root.api_url}/v2/cameras/${this.selected.exid}/nvr/snapshots/extract`,
              data: {
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
            }).then(response => {
              if (response.status == 200) {
                this.showSuccessMsg({
                  title: "Success",
                  message: "Snapshot Extractor has been added (Local)!"
                });

                this.$events.fire('se-added', {})
                this.clearForm()
              } else {
                this.showErrorMsg({
                  title: "Error",
                  message: "Something went wrong!"
                })
              }
            })
          }
        }
      },
      clearForm () {
        this.errors = [];
        this.cameras = [];
        this.selected = null;
        this.showSchedule = true;
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
        this.clearCalendar();
        this.showExModal = false;
        this.account = "-1";
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
      },

      clearCalendar () {
        let events = this.calendar.getEvents()

        events.forEach((event) => {
          let findingID = null
          if (event.id === "") {
            findingID = event.el
          } else {
            findingID = event.id
          }
          let removeEvent = this.calendar.getEventById( findingID )
          removeEvent.remove();
        });
      }
    }
  }
</script>