<template>
  <div>
    <form>
      <div class="form-row">
        <div class="col-2">
          <select v-model="map_request" class="form-control map-input" @change="handleChange()">
            <option value="construction">Construction Only</option>
            <option value="garda">Garda</option>
            <option value="all">All</option>
          </select>
        </div>
      </div>
    </form>
    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
    <gmap-map :center="center" :zoom="7" style="width: 100%; height: 800px">
      <gmap-info-window :options="infoOptions" :position="infoWindowPos" :opened="infoWinOpen" @closeclick="infoWinOpen=false">
        <span v-html="infoContent"></span>
      </gmap-info-window>

      <gmap-marker :key="i" v-for="(m,i) in markers" :position="m.position" :clickable="true" @click="toggleInfoWindow(m,i)" :icon="{url: m.status}"></gmap-marker>
    </gmap-map>
  </div>
</template>

<style scoped>
table {
  max-width: 300px;
}

table th {
  font-size: 12px;
  vertical-align: middle;
  padding-right: 0px;
}

table td {
  font-size: 11px;
  padding-right: 0px;
}

.gm-style .gm-style-iw {
  padding-left: 10px;
}

.gm-style img {
  max-width: 300px;
  padding-top: 20px;
}

.table {
  margin: 0px;
}

.form-row {
  margin: 10px;
}

.map-input {
  width: 146px;
}
</style>

<script>
import axios from "axios";

export default {
  data: () => {
    return {
      center: {
        lat: 52.8999964,
        lng: -3.8499966
      },
      infoContent: '',
      infoWindowPos: null,
      infoWinOpen: false,
      currentMidx: null,
      //optional: offset infowindow so it visually sits nicely on top of our marker
      infoOptions: {
        pixelOffset: {
          width: 0,
          height: -35
        }
      },
      markers: [],
      ajaxWait: true,
      map_request: "construction"
    }
  },

  created() {
    this.fetchMarkers(this.map_request)
  },

  methods: {

    handleChange() {
      let map_request = this.map_request;
      this.markers = []
      this.ajaxWait = true;
      this.fetchMarkers(map_request)
    },

    fetchMarkers (map_request) {
      axios.get("/v1/maps", {
        params: {
          map_for: map_request,
        }
      }).then(response => {
        this.ajaxWait = false;
        this.markers = response.data.markers;
      });
    },
    toggleInfoWindow: function(marker, idx) {
      this.infoWindowPos = marker.position;
      this.infoContent = marker.infoText;

      //check if its the same marker that was selected if yes toggle
      if (this.currentMidx == idx) {
        this.infoWinOpen = !this.infoWinOpen;
      }
      //if different marker set infowindow to open and reset current marker index
      else {
        this.infoWinOpen = true;
        this.currentMidx = idx;

      }
    }

  }
}
</script>