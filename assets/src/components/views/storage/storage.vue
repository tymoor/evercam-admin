<template>
  <div>

    <div>
      <div class="row cameras-filter_css">
        <form>
          <div class="form-row">
            <div class="col-0.5 search-label">
              <label class="control-label">Year :</label>
            </div>
            <div class="col">
              <select v-model="year" @change="storageYearChange" class="form-control">
                <option value="2015">2015</option>
                <option value="2016">2016</option>
                <option value="2017">2017</option>
                <option value="2018">2018</option>
                <option value="2019">2019</option>
              </select>
            </div>
          </div>
        </form>
      </div>
    </div>

    <v-horizontal-scroll />

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          :api-mode="false"
          :fields="fields"
          pagination-path="pagination"
          :per-page="perPage"
          :data-manager="dataManager"
          @vuetable:pagination-data="onPaginationData"
          @vuetable:initialized="onInitialized"
          @vuetable:loading="showLoader"
          @vuetable:loaded="hideLoader"
          :css="css.table"
        >
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div class="field perPage-margin">
          <label>Per Page:</label>
          <select class="ui simple dropdown" v-model="perPage">
            <option :value="100">100</option>
            <option :value="500">500</option>
            <option :value="1000">1000</option>
          </select>
        </div>
        <vuetable-pagination-info ref="paginationInfo"
        ></vuetable-pagination-info>
        <component :is="paginationComponent" ref="pagination"
          @vuetable-pagination:change-page="onChangePage"
        ></component>
      </div>
    </div>
</div>
</template>

<style scoped>
.perPage-margin {
  margin-top: 5px;
}

.overflow-forms {
  width: 85%;
}

#table-wrapper {
  margin-top: 1px;
}

#api-wait {
  left: 50%;
  position: fixed;
  top: 50%;
  z-index: 99999;
}

.email-template {
  cursor: pointer;
}

.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}

</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import Jquery from "jquery";
import axios from "axios";
import _ from "lodash";

export default {
  data: () => {
    return {
      loading: "",
      perPage: 1000,
      css: TableWrapper,
      moreParams: {},
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      data: [],
      filtered: [],
      ajaxWait: true,
      year: "2016"
    }
  },
  watch: {
    data(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.data);
      });
    },
    filtered(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.filtered);
      });
    },
    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(paginationData);
      });
    }
  },

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.ajaxWait = true,
    axios.get("/v1/storage").then(response => {
      this.data = response.data.data;
      this.ajaxWait = false;
      this.filtered = response.data.data;
    });
  },

  updated() {
    document.addEventListener("resize", this.setScrollBar());
    this.appendOtherData(this.data, true);
  },

  methods: {

    clearTable(data) {

      NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
      HTMLCollection.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];

      let allTableRows = document.getElementsByTagName("table")[0].rows;

      if (allTableRows.length > 3) {
        data.forEach((camera, i) => {
          Jquery(allTableRows[i + 1]).find('.vuetable-td-jan').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-feb').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-mar').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-apr').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-may').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-jun').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-jul').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-aug').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-sep').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-oct').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-nov').css('background-color', 'white');
          Jquery(allTableRows[i + 1]).find('.vuetable-td-dec').css('background-color', 'white');
        });
      }

    },

    appendOtherData(data, oldestLatest) {

      NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
      HTMLCollection.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];

      let allTableRows = document.getElementsByTagName("table")[0].rows;

      let storage = []
      if (allTableRows.length > 3) {
        data.forEach((camera, i) => {
          let cameraAPID = camera.api_id
          let cameraAPIKey = camera.api_key
          let cameraExid = camera.exid

          if (oldestLatest) {
            let latest = `https://media.evercam.io/v2/cameras/${cameraExid}/recordings/snapshots/latest?api_id=${cameraAPID}&api_key=${cameraAPIKey}`
            let oldest = `https://media.evercam.io/v2/cameras/${cameraExid}/recordings/snapshots/oldest?api_id=${cameraAPID}&api_key=${cameraAPIKey}`

            axios.get(latest).then(response => {
              let data = response.data;
              Jquery(allTableRows[i + 1]).find('.vuetable-td-latest-image-date').text(`${data.created_at}`);
            }).catch(error => {
              Jquery(allTableRows[i + 1]).find('.vuetable-td-latest-image-date').text(``);
            });

            axios.get(oldest).then(response => {
              let data = response.data;
              Jquery(allTableRows[i + 1]).find('.vuetable-td-oldest-image-date').text(`${data.created_at}`);
            }).catch(error => {
              Jquery(allTableRows[i + 1]).find('.vuetable-td-oldest-image-date').text(``);
            });
          } else {
            console.log("No new OldestLatest.")
          }

          let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
          let january = ""
          let feburary = ""
          let march = ""
          let april = ""
          let may = ""
          let june = ""
          let july = ""
          let august = ""
          let september = ""
          let october = ""
          let november = ""
          let december = ""

          months.forEach((month) => {
            let httpURL = `https://media.evercam.io/v2/cameras/${cameraExid}/recordings/snapshots/${this.year}/${month}/days?api_id=${cameraAPID}&api_key=${cameraAPIKey}`

            axios.get(httpURL).then(response => {
              let monthData = response.data.days

              if (monthData.length > 0) {
                if (month == "01") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jan').css('background-color', 'black');
                }

                if (month == "02") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-feb').css('background-color', 'black');
                }
                
                if (month == "03") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-mar').css('background-color', 'black');
                }
                
                if (month == "04") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-apr').css('background-color', 'black');
                }
                
                if (month == "05") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-may').css('background-color', 'black');
                }
                
                if (month == "06") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jun').css('background-color', 'black');
                }
                
                if (month == "07") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jul').css('background-color', 'black');
                }
                
                if (month == "08") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-aug').css('background-color', 'black');
                }

                if (month == "09") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-sep').css('background-color', 'black');
                }

                if (month == "10") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-oct').css('background-color', 'black');
                }

                if (month == "11") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-nov').css('background-color', 'black');
                }

                if (month == "12") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-dec').css('background-color', 'black');
                }
              } else {
                console.log("do nothing");
              }

            }).catch(error => {});
          });
        });
      }
    },

    storageYearChange () {
      this.ajaxWait = true;
      this.clearTable(this.data)
      this.appendOtherData(this.data, false)
      this.ajaxWait = false;
    },

    onPaginationData(paginationData) {
      this.$refs.pagination.setPaginationData(paginationData);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
    },

    dataManager(sortOrder, pagination) {
      if (this.data.length < 1) return;

      let local = this.data;

      // sortOrder can be empty, so we have to check for that as well
      if (sortOrder.length > 0) {
        console.log("orderBy:", sortOrder[0].sortField, sortOrder[0].direction);
        local = _.orderBy(
          local,
          sortOrder[0].sortField,
          sortOrder[0].direction
        );
      }

      pagination = this.$refs.vuetable.makePagination(
        local.length,
        this.perPage
      );
      console.log('pagination:', pagination)
      let from = pagination.from - 1;
      let to = from + this.perPage;

      return {
        pagination: pagination,
        data: _.slice(local, from, to)
      };
    },

    onInitialized(fields) {
      this.vuetableFields = fields.filter(field => field.togglable);
    },

    showLoader() {
      this.loading = "loading";
    },

    hideLoader() {
      this.loading = "";
    }
  }
}
</script>