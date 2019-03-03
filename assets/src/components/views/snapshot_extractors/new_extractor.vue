<template>
  <div>
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
          <date-picker v-model="fromDateTime" ref="datepicker1" type="datetime" lang="en" :format="dateFormat" confirm value-type="format" @confirm="setFromDate"></date-picker>
        </div>
      </div>
      <div class="form-group row">
        <label class="col-sm-4 col-form-label">To DateTime</label>
        <div class="col-sm-8">
          <date-picker v-model="toDateTime" ref="datepicker2" type="datetime" lang="en" :format="dateFormat" confirm value-type="format" @confirm="setToDate"></date-picker>
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
        <div class="col-sm-12">
          <full-calendar
            style="padding-left: 0px;"
            ref="calendar"
            :config="config"
            :events="config.events"
            :key="componentKey"
            id="calendar"
          ></full-calendar>
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
    </form>
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
  width: 500px;
  max-width: 610px;
  margin-top: 114.5px;
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

</style>

<script>
import { FullCalendar } from 'vue-full-calendar';
import { CoolSelect } from "vue-cool-select";
import DatePicker from 'vue2-datepicker';
import moment from "moment";

  export default {
    components: {
      CoolSelect, DatePicker, FullCalendar
    },
    data: () => {
      return {
        events: null,
        componentKey: 0,
        cameras: [],
        camera: "",
        selected: null,
        showSchedule: false,
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
          "Monday": ["00:00-23:59"],
          "Tuesday": ["00:00-23:59"],
          "Wednesday": ["00:00-23:59"],
          "Thursday": ["00:00-23:59"],
          "Friday": ["00:00-23:59"],
          "Saturday": ["00:00-23:59"],
          "Sunday": ["00:00-23:59"]
        }),
        config: {
          axisFormat: 'HH',
          allDaySlot: false,
          columnFormat: 'ddd',
          defaultDate: '1969-12-29',
          slotDuration: '00:60:00',
          defaultView: 'agendaWeek',
          dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
          eventColor: '#007bff',
          editable: true,

          eventLimit: true,
          eventOverlap: false,
          firstDay: 1,
          agoDayHide: 0,
          header: {
            left: '',
            center: '',
            right: '',
          },
          events: [],
          height: 'auto',
          selectHelper: true,
          selectable: true,
          timezone: 'local',
          select: (start, end) => {
            let eventData
            eventData = {
              start: start,
              end: end
            }
            console.log(eventData)
            this.$refs.calendar.fireMethod('renderEvent', eventData, true);
            this.$refs.calendar.fireMethod('unselect');
            var schedule = JSON.stringify(this.parseCalendar());
            this.myschedule = schedule
          },
          eventClick: (event, element) => {
            event.preventDefault
            if (window.confirm("Are you sure you want to delete this event?")){
              this.$refs.calendar.fireMethod('removeEvents', event._id);
            }
          },
          eventResize: (event) => {
            this.$refs.calendar.$emit('refetch-events')
            var schedule = JSON.stringify(this.parseCalendar());
            this.schedule = schedule
          }
        },
        dateFormat: {
          stringify: (date) => {
            return date ? moment(date).format("YYYY-MM-DD hh:mm:ss") : null
          },
          parse: (value) => {
            return value ? moment(value, 'YYYY-MM-DD hh:mm:ss').toDate() : null
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
      }
    },

    beforeUpdate() {
      console.log("called")
    },

    methods: {

      renderEventunSelect(eventData) {
        this.$refs.calendar.fireMethod('renderEvent', eventData, true);
        this.$refs.calendar.fireMethod('unselect');
      },

      handleChange() {
        if (this.schedule_type === "continuous"){
          this.schedule = {
            "Monday": ["00:00-23:59"],
            "Tuesday": ["00:00-23:59"],
            "Wednesday": ["00:00-23:59"],
            "Thursday": ["00:00-23:59"],
            "Friday": ["00:00-23:59"],
            "Saturday": ["00:00-23:59"],
            "Sunday": ["00:00-23:59"]
          }
          this.schedule = JSON.stringify(this.schedule);
          this.config.events = null
          this.config.eventSources = null
        } else {
          if (this.schedule_type === "working_hours"){
            this.config.editable = false
            this.config.selectable = false
            if (!this.config.events){
              this.config.events = [
                {
                  _id: "0",
                  start: '1969-12-29T08:00:00',
                  end: '1969-12-29T18:00:00',
                },
                {
                  _id: "1",
                  start: '1969-12-30T08:00:00',
                  end: '1969-12-30T18:00:00',
                },
                {
                  _id: "2",
                  start: '1969-12-31T08:00:00',
                  end: '1969-12-31T18:00:00',
                },
                {
                  _id: "3",
                  start: '1970-01-01T08:00:00',
                  end: '1970-01-01T18:00:00',
                },
                {
                  _id: "4",
                  start: '1970-01-02T08:00:00',
                  end: '1970-01-02T18:00:00',
                },
              ]
            }
            this.schedule = {
              "Monday": ["08:00-18:00"],
              "Tuesday": ["08:00-18:00"],
              "Wednesday": ["08:00-18:00"],
              "Thursday": ["08:00-18:00"],
              "Friday": ["08:00-18:00"],
              "Saturday": [],
              "Sunday": []
            }
            this.schedule = JSON.stringify(this.schedule);
          } else if (this.schedule_type === "on_schedule") {
            this.config.editable = true
            this.config.selectable = true

            console.log(this.$el)
            console.log(this.$refs)
            var events = this.$refs.calendar.fireMethod('clientEvents');
            events.preventDefault
            for (var i = 0; i < events.length; i++) {
              this.$refs.calendar.fireMethod('removeEvents', events[i]._id);
            }

            this.config.events = null
            this.config.eventSources = null
          }
        }
        this.componentKey += 1;
        console.log(this.schedule);
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

          console.log(this.items);
        }, 500);
      },

      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        // if (this.model_exid == "") {
        //   this.errors.push("Model id cannot be empty.")
        // }

        if (Object.keys(this.errors).length === 0) {

          let params = {
          }
          this.$http.post("/v1/snapshot_extractors", {...params}).then(response => {

            this.$notify({
              group: "admins",
              title: "Info",
              type: "success",
              text: "Snapshot Extractor has been added!",
            });

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
      },
      clearForm () {
        this.errors = [],
        this.selected = null
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