<template>
  <div>
    <div class="overflow-forms">
      <construction-filters />
    </div>
    <div>
      <con-show-hide :vuetable-fields="vuetableFields" />
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
  overflow: hidden;
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
import ConstructionFilters from "./construction_filters";
import ConShowHide from "./con_show_hide.vue";

export default {
  components: {
    ConstructionFilters, ConShowHide
  },
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
      ajaxWait: true
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
    this.getNvrData("owner_id=13959")
    this.$events.$on('construction-filter-set', eventData => this.onFilterSet(eventData))
  },

  updated() {
    document.addEventListener("resize", this.setScrollBar());
    this.appendOtherData(this.data);
  },

  methods: {

    onFilterSet(params) {
      this.ajaxWait = true
      window.stop()
      this.clearAllData(this.data)
      this.getNvrData(params.account)
    },

    getNvrData(params) {
      axios.get(`/v1/nvrs?${params}`).then(response => {
        this.data = response.data.data;
        this.ajaxWait = false;
        this.filtered = response.data.data;
      });
    },

    appendOtherData(data) {

      NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
      HTMLCollection.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];

      let allTableRows = document.getElementsByTagName("table")[0].rows;

      if (allTableRows.length > 3) {
        data.forEach((camera, i) => {
          let cameraAPID = camera.api_id
          let cameraAPIKey = camera.api_key
          let cameraExid = camera.exid
          let httpURL = `https://media.evercam.io/v2/cameras/${cameraExid}/nvr/stream/info?api_id=${cameraAPID}&api_key=${cameraAPIKey}`

          axios.get(httpURL).then(response => {
            let nvrData = response.data
            let model = nvrData.device_info.model || ""
            let device = nvrData.device_info.device_name || ""
            let mac_address = nvrData.device_info.mac_address || ""
            let firmware_version = nvrData.device_info.firmware_version || ""
            let resolution = nvrData.stream_info.resolution || ""
            let bitrate_type = nvrData.stream_info.bitrate_type || ""
            let video_quality = nvrData.stream_info.video_quality || ""
            let frame_rate = nvrData.stream_info.frame_rate || ""
            let bitrate = nvrData.stream_info.bitrate || ""
            let video_encoding = nvrData.stream_info.video_encoding || ""
            let hdd_info = nvrData.hdd_info || ""
            let time_mode = nvrData.time_info.time_mode || ""
            let local_time = nvrData.time_info.local_time || ""
            let timezone = nvrData.time_info.timezone || ""
            let addressing_format_type = nvrData.ntp_server_info.addressing_format_type || ""
            let host_name = nvrData.ntp_server_info.host_name || ""
            let port_no = nvrData.ntp_server_info.port_no || ""
            let synchronize_interval = nvrData.ntp_server_info.synchronize_interval || ""
            let nvrStatus = (Object.keys(nvrData.device_info).length > 0) ? "Online" : "Offline"
            let hdd_name = ""
            let hdd_capacity = ""
            let free_space = ""
            let status = ""
            let property = ""
            if (Object.keys(hdd_info).length > 0) {
              hdd_info.map((hdd) => {
                hdd_name += "<div>" + hdd.name + "</div>";
                hdd_capacity += "<div>" + hdd.capacity + "</div>";
                free_space += "<div>" + hdd.free_space + "</div>";
                status += "<div>" + hdd.status + "</div>";
                property += "<div>" + hdd.property + "</div>";
              })
            }

            // list to update
            Jquery(allTableRows[i + 1]).find('.vuetable-td-model').text(`${model}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-device').text(`${device}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-mac_address').text(`${mac_address}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-firmware').text(`${firmware_version}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-resolution').text(`${resolution}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-bitrate_type').text(`${bitrate_type}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-video_quality').text(`${video_quality}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-fps').text(`${frame_rate}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-max_bitrate').text(`${bitrate}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-encoding').text(`${video_encoding}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-hdd_name').html(`${hdd_name}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-hdd_capacity').html(`${hdd_capacity}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-hd_free_space').html(`${free_space}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-status').html(`${status}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-property').html(`${property}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-nvr_status').text(`${nvrStatus}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-time_mode').text(`${time_mode}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-local_time').text(`${local_time}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-timezone').text(`${timezone}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-addressing_format_type').text(`${addressing_format_type}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-host_name').text(`${host_name}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-port_no').text(`${port_no}`)
            Jquery(allTableRows[i + 1]).find('.vuetable-td-synchronize_interval').text(`${synchronize_interval}`)

          }).catch(error => {
            Jquery(allTableRows[i + 1]).find('.vuetable-td-nvr_status').text(`Offline`) 
          });

        });
      }
    },

    clearAllData(data) {
      NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
      HTMLCollection.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];

      let allTableRows = document.getElementsByTagName("table")[0].rows;

      if (allTableRows.length > 3) {
        data.forEach((camera, i) => {
          Jquery(allTableRows[i + 1]).find('.vuetable-td-model').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-device').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-mac_address').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-firmware').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-resolution').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-bitrate_type').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-video_quality').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-fps').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-max_bitrate').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-encoding').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-hdd_name').html(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-hdd_capacity').html(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-hd_free_space').html(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-status').html(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-property').html(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-nvr_status').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-time_mode').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-local_time').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-timezone').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-addressing_format_type').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-host_name').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-port_no').text(``)
          Jquery(allTableRows[i + 1]).find('.vuetable-td-synchronize_interval').text(``)
        })
      }
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