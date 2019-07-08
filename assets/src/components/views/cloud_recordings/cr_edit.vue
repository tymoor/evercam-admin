<template>
  <div v-if="showCRModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h3 class="modal-title">
              Cloud Recordings - {{ camera_name }}
            </h3>
          </div>
          <div class="modal-body">

            <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

            <ul class="nav nav-tabs" role="tablist">
              <li class="nav-item">
                <a class="nav-link active" data-toggle="tab" href="#edit" role="tab" aria-controls="edit" @click="showCREFooter">Edit</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" data-toggle="tab" href="#delete" role="tab" aria-controls="delete" @click="showCRDFooter">Delete</a>
              </li>
            </ul>

            <div class="tab-content">
              <div class="tab-pane active" id="edit" role="tabpanel">

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
              <div class="tab-pane" id="delete" role="tabpanel">

                <div class="alert alert-success" role="alert">
                  <h4 class="alert-heading">NOTE:</h4>
                  <p>You can delete no more than 60 minutes of footage at a time and both URLs below must be from within the same hour.</p>
                  <hr>
                  <p class="mb-0">If you need to delete more, ask marco@evercam.io</p>
                </div>

                <form>
                  <div class="form-group">
                    <label>Start URL:</label>
                    <input class="form-control" type="text" placeholder="Start URL" autocomplete="off" v-model="startURL">
                    <div class="invalid-feedback">Please provide a valid informations.</div>
                  </div>
                  <div class="form-group">
                    <label>End URL:</label>
                    <input class="form-control" type="text" placeholder="End URL" autocomplete="off" v-model="endURL">
                    <div class="invalid-feedback">Please provide a valid informations.</div>
                  </div>
                </form>
                <div v-if='imageCount == 0' class="alert alert-danger" role="alert">No Jpegs are available for deletion.</div>
                <p v-if="errors.length">
                  <b>Please correct the following error(s):</b>
                  <div v-for="error in errors" class="alert alert-danger" role="alert">{{ error }}</div>
                </p>
              </div>
            </div>
          </div>
          <div class="modal-footer" v-show="cr_edit_footer">
            <button type="button" class="btn btn-primary" @click="SaveCR()"> Save </button>
            <button type="button" class="btn btn-primary" @click="hideCRModal()"> Close </button>
          </div>
          <div class="modal-footer" v-show="cr_delete_footer">
            <button type="button" class="btn btn-danger" @click="deleteCR()"> Delete </button>
            <button type="button" class="btn btn-primary" @click="hideCRDModal()"> Close </button>
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
  width: 570px;
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
        cr_edit_footer: true,
        cr_delete_footer: false,
        imageCount: -1,
        errors: [],
        startURL: "",
        endURL: "",
        showCalendar: false,
        status: "",
        camera_name: "",
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
        this.exid = this.crSettings.exid,
        this.camera_name = this.crSettings.camera_name,
        this.startURL = `https://dash.evercam.io/v2/cameras/${this.exid}/recordings/snapshots/`,
        this.endURL = `https://dash.evercam.io/v2/cameras/${this.exid}/recordings/snapshots/`
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

        this.$http.post(`${this.$root.api_url}/v2/cameras/${this.exid}/apps/cloud-recording`, {...params}).then(response => {

          this.showSuccessMsg({
            title: "Success",
            message: "Cloud Recordings have been updated!"
          })

          this.ajaxWait = false
          // clear all evenrts here
          this.showCalendar = false;
          this.$events.fire("close-cr-modal", false);
          this.$events.fire("refresh-cr-table", true);

        }, error => {
          console.log(error)
          this.ajaxWait = false
          this.showErrorMsg({
            title: "Error",
            message: `${error.statusText}`
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
        this.cr_delete_footer = false;
        this.cr_edit_footer = true;
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
      },

      showCREFooter() {
        this.cr_edit_footer = true,
        this.cr_delete_footer = false;
      },

      showCRDFooter() {
        this.cr_edit_footer = false,
        this.cr_delete_footer = true;
      },

      hideCRDModal() {
        this.showCalendar = false,
        this.destroyCalendar(),
        this.cr_edit_footer = true,
        this.cr_delete_footer = false,
        this.errors = [],
        this.startURL = "",
        this.endURL = "",
        this.imageCount = -1,
        this.ajaxWait = false,
        this.$events.fire("close-cr-modal", false)
      },

      extractDate(url) {
        return url.substr(url.lastIndexOf('/') + 1);
      },

      outOfHourRange(start, end) {
        if (moment(start).get("hour") == moment(end).get("hour")) {
          return false;
        } else {
          return true;
        }
      },

      isValidURL(url) {
        return /^(http(s)?:\/\/)?(www\.)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/.test(url);
      },

      countJpegs(start, end) {
        this.ajaxWait = true;
        let camera_exid = this.exid;

        let from_date = this.extractDate(start)
        let to_date = this.extractDate(end)

        axios.get(`https://media.evercam.io/v2/cameras/${camera_exid}/recordings/snapshots`, {
          params: {
            api_id: this.api_id,
            api_key: this.api_key,
            limit: 3600,
            page: 1,
            from: from_date,
            to: to_date
          }
        }).then(response => {
          this.imageCount = response.data.snapshots.length
          this.ajaxWait = false
          if (this.imageCount > 0) {
            if (window.confirm(`Are you sure you want to delete ${this.imageCount} images?`)) {
              this.deleteJpegs(from_date, to_date);
              this.hideCRDModal();
            }
          }
        });
      },

      deleteCR() {
        let startURL = this.startURL;
        let endURL = this.endURL;

        let startExrtactedData = this.extractDate(startURL)
        let endExrtactedData = this.extractDate(endURL)

        this.errors = []

        if (!this.isValidURL(startURL) && !this.isValidURL(endURL)) {
          this.errors.push("Please enter valid URLs.");
        }

        if (moment(startExrtactedData).unix() > moment(endExrtactedData).unix()) {
          this.errors.push("Start date cannot be greater than end date.");
        }

        if (this.outOfHourRange(startExrtactedData, endExrtactedData) == true) {

          this.errors.push("You can only delete within an hour range.");
        }

        if (this.errors.length === 0) {
          this.countJpegs(startURL, endURL)
        }
      },

      deleteJpegs(start, end) {
        let from_date = moment(start).unix() - 1;
        let to_date = moment(end).unix();

        let params = {
          api_id: this.api_id,
          api_key: this.api_key,
          from_date: from_date,
          to_date: to_date,
          admin_email: this.$root.user.email,
          admin_fullname: `${this.$root.user.firstname} ${this.$root.user.lastname}`,
          image_count: this.imageCount
        }

        this.$http.delete(`https://media.evercam.io/v2/cameras/${this.exid}/recordings/snapshots`, {params: params}).then(response => {
          this.showSuccessMsg({
            title: "Success",
            message: "Deletion Process has been started."
          });
        }, error => {
          this.showErrorMsg({
            title: "Error",
            message: "Something went wrong."
          });
        });
      }
    }
  }
</script>