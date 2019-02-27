<template>
  <div>
    <gmap-map :center="center" :zoom="15" style="width: 100%; height: 500px">
      <gmap-info-window :options="infoOptions" :position="infoWindowPos" :opened="infoWinOpen" @closeclick="infoWinOpen=false">
        {{infoContent}}
      </gmap-info-window>

      <gmap-marker :key="i" v-for="(m,i) in markers" :position="m.position" :clickable="true" @click="toggleInfoWindow(m,i)"></gmap-marker>
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

.gm-style .map-thumbnail-img {
  max-width: 300px;
  padding-top: 20px;
}

.table {
  margin: 0px;
}
</style>

<script>
export default {
  data: () => {
    return {
      center: {
        lat: 47.376332,
        lng: 8.547511
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
      markers: [{
        position: {
          lat: 47.376332,
          lng: 8.547511
        },
        infoText: 'Marker 1'
      }, {
        position: {
          lat: 47.374592,
          lng: 8.548867
        },
        infoText: 'Marker 2'
      }, {
        position: {
          lat: 47.379592,
          lng: 8.549867
        },
        infoText: 'Marker 3'
      }]
    }
  },
  methods: {
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