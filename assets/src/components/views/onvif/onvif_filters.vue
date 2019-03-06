<template>
  <div class="row cameras-filter_css">
    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
    <form>
      <div class="form-row">
        <div class="col">
          <select v-model="service" class="form-control margin-left-10 width-200">
            <option v-for="(item, index) in list" v-bind:value="index">{{ index }}</option>
          </select>
        </div>
        <div class="col">
          <select v-model="operations" class="form-control margin-left-10 width-200">
            <option v-for="option in list[service]" v-bind:value="option">{{option}}</option>
          </select>
        </div>
        <div class="col">
          <select class="form-control is-required" autocomplete="off" v-model="onvifCamera">
            <option v-for="camera in cameras" v-bind:value="camera.onvif_url">
              {{ camera.name }}
            </option>
          </select>
        </div>
        <div class="col">
          <button @click="onvifSearch" type="button" class="btn btn-primary">Search</button>
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

.menu-width-select {
  width: 300px;
}

.width-200 {
  width: 200px;
}


</style>

<script>
import axios from "axios";

export default {
  data () {
    return {
      ajaxWait: false,
      cameras: [],
      onvifCamera: "",
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

  mounted(){
    this.fetchCameras()
  },

  methods: {

    fetchCameras () {
      this.$http.get("/v1/onvif_cameras").then(response => {
        this.cameras = response.body.onvif_cameras;
      }, error => {
        console.error(error);
      });
    },

    onvifSearch() {
      console.log(this.service)
      console.log(this.operations)
      this.ajaxWait = true

      axios.get(`https://media.evercam.io/v2/onvif/v20/${this.service}/${this.operations}?${this.onvifCamera}`).then(response => {
        this.ajaxWait = false
        this.$events.fire('json-set', response.data)
      }).catch(error => {
        this.$events.fire('json-set', JSON.parse(error.response.request.responseText))
        this.ajaxWait = false
      });
    }
  }
}
</script>
