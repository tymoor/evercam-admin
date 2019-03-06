<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col">
          <select v-model="service" class="form-control margin-left-10">
            <option v-for="(item, index) in list">{{ index }}</option>
          </select>
        </div>
        <div class="col">
          <select v-model="operations" class="form-control margin-left-10">
            <option v-for="option in list[service]" v-bind:value="option">{{option}}</option>
          </select>
        </div>
        <div class="col">
          <cool-select
            class="margin-left-10"
            v-model="selected"
            :items="items"
            :loading="loading"
            item-text="name"
            placeholder="Enter Camera name"
            disable-filtering-by-search
            :reset-search-on-blur="true"
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
    </form>
  </div>
</template>

<style scoped>
.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.margin-left-10 {
  margin-left: 10px;
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
import { CoolSelect } from "vue-cool-select";

export default {
  components: {
    CoolSelect
  },
  data () {
    return {
      cameras: [],
      items: [],
      loading: false,
      timeoutId: null,
      noData: false,
      selected: null,
      service: "device_service",
      operations: "GetAccessPolicy",
      list: {
        "device_service": [
          "GetAccessPolicy",
          "GetCACertificates",
          "GetCertificates",
          "GetCertificatesStatus",
          "GetClientCertificateMode",
          "GetDeviceInformation",
          "GetDiscoveryMode",
          "GetDNS",
          "GetDot11Capabilities",
          "GetDot1XConfigurations",
          "GetDPAddresses",
          "GetDynamicDNS",
          "GetEndpointReference",
          "GetGeoLocation",
          "GetHostname",
          "GetIPAddressFilter",
          "GetNetworkDefaultGateway",
          "GetNetworkInterfaces",
          "GetNetworkProtocols",
          "GetNTP",
          "GetRelayOutputs",
          "GetRemoteDiscoveryMode",
          "GetRemoteUser",
          "GetScopes",
          "GetServiceCapabilities",
          "GetStorageConfigurations",
          "GetSystemDateAndTime",
          "GetSystemSupportInformation",
          "GetSystemUris",
          "GetUsers",
          "GetWsdlUrl",
          "GetZeroConfiguration"
        ],
        "Media": [
          "GetAudioDecoderConfigurations",
          "GetAudioEncoderConfigurations",
          "GetAudioOutputConfigurations",
          "GetAudioOutputs",
          "GetAudioSourceConfigurations",
          "GetAudioSources",
          "GetMetadataConfigurations",
          "GetProfiles",
          "GetServiceCapabilities",
          "GetVideoAnalyticsConfigurations",
          "GetVideoEncoderConfigurations",
          "GetVideoSourceConfigurations",
          "GetVideoSources",
          "GetSnapshotUri",
          "GetStreamUri"
        ],
        "Display": [
          "GetServiceCapabilities"
        ],
        "Analytics": [
          "GetAnalyticsEngineControls"
        ],
        "AnalyticsDevice": [
          "GetAnalyticsEngineInputs",
          "GetAnalyticsEngines",
          "GetServiceCapabilities"
        ],
        "DeviceIO": [
          "GetAudioOutputs",
          "GetAudioSources",
          "GetDigitalInputs",
          "GetRelayOutputs",
          "GetSerialPorts",
          "GetServiceCapabilities",
          "GetVideoOutputs",
          "GetVideoSources"
        ],
        "Imaging": [
          "GetServiceCapabilities"
        ],
        "receiver_service": [
          "GetReceivers",
          "GetServiceCapabilities"
        ]
      }
    };
  },

  methods: {
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
  }
}
</script>
