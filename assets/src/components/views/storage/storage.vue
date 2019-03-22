<template>
  <div>

    <div>
      
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
            <option :value="60">60</option>
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
      year: 2016
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

    this.$events.$on('storage-filter-set', eventData => this.onFilterSet(eventData))
  },

  updated() {
    document.addEventListener("resize", this.setScrollBar());
    this.appendOtherData(this.data);
  },

  methods: {

    appendOtherData(data) {

      NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
      HTMLCollection.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];

      let allTableRows = document.getElementsByTagName("table")[0].rows;

      let storage = []
      if (allTableRows.length > 3) {
        data.forEach((camera, i) => {
          let cameraAPID = camera.api_id
          let cameraAPIKey = camera.api_key
          let cameraExid = camera.exid

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
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jan').text(`Yes`)
                }

                if (month == "02") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-feb').text(`Yes`)
                }
                
                if (month == "03") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-mar').text(`Yes`)
                }
                
                if (month == "04") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-apr').text(`Yes`)
                }
                
                if (month == "05") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-may').text(`Yes`)
                }
                
                if (month == "06") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jun').text(`Yes`)
                }
                
                if (month == "07") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jul').text(`Yes`)
                }
                
                if (month == "08") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-aug').text(`Yes`)
                }

                if (month == "09") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-sep').text(`Yes`)
                }

                if (month == "10") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-oct').text(`Yes`)
                }

                if (month == "11") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-nov').text(`Yes`)
                }

                if (month == "12") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-dec').text(`Yes`)
                }
              } else {
                if (month == "01") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jan').text(`No`)
                }

                if (month == "02") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-feb').text(`No`)
                }
                
                if (month == "03") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-mar').text(`No`)
                }
                
                if (month == "04") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-apr').text(`No`)
                }
                
                if (month == "05") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-may').text(`No`)
                }
                
                if (month == "06") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jun').text(`No`)
                }
                
                if (month == "07") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-jul').text(`No`)
                }
                
                if (month == "08") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-aug').text(`No`)
                }

                if (month == "09") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-sep').text(`No`)
                }

                if (month == "10") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-oct').text(`No`)
                }

                if (month == "11") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-nov').text(`No`)
                }

                if (month == "12") {
                  Jquery(allTableRows[i + 1]).find('.vuetable-td-dec').text(`No`)
                }
              }

            }).catch(error => {});
          });
        });
      }
    },

    onFilterSet (filter) {
      this.year = filter.year;
      this.ajaxWait = true;
      this.appendOtherData(this.data)
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