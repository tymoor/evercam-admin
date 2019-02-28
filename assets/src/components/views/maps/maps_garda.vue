<template>
  <div>
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
</style>

<script>
import axios from "axios";

export default {
  data: () => {
    return {
      center: {
        lat: 53.412910,
        lng: -8.243890
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
      markers: []
    }
  },

  created() {
    this.fetchMarkers()
  },

  methods: {
    fetchMarkers () {
      axios.get("/v1/maps", {
        params: {
          map_for: "garda",
        }
      }).then(response => {
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