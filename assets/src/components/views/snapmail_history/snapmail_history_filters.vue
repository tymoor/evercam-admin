<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Search" autocomplete="off" v-model="search" @keyup="snapmailHistoryFilterGlobal">
        </div>
        <div class="col">
           <date-picker v-model="dateTime" ref="datepicker" @change="handleChange" lang="en" range :format="dateFormat" value-type="format"></date-picker>
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

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}

.mx-shortcuts-wrapper {
  display: none;
}
</style>

<script>
import DatePicker from 'vue2-datepicker'
import moment from "moment";

export default {
  components: { DatePicker },
  data () {
    return {
      search: "",
      dateTime: "",
      allParams: {},
      dateParams: {},
      lang: {
        days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        pickers: [],
        placeholder: {
          dateRange: 'Select Date Range'
        }
      },
      dateFormat: {
        stringify: (date) => {
          return date ? moment(date).format("YYYY/MM/DD") : null
        },
        parse: (value) => {
          return value ? moment(value, 'YYYY/MM/DD').toDate() : null
        }
      }
    }
  },
  methods: {
    handleChange(val) {
      console.log(val)
      this.dateParams.fromDate = val[0]
      this.dateParams.toDate = val[1]
      this.$events.fire('snapmail-history-date-filter-set', this.dateParams)
    },

    snapmailHistoryFilterGlobal () {
      this.allParams.search = this.search
      this.$events.fire('snapmail-history-filter-set', this.allParams)
    }
  }
}
</script>