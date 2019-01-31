<template>
  <div class="row overlapping">
    <div class="form-camera-report">
      <div class="filter-naming">
        Search :
      </div>
      <div class="camera-inputs">
        <input type="text" class="first-inps" placeholder="ID" id="camera-id" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Owner" id="owner" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Camera Name" id="camera-name" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Camera IP" id="camera-ip" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Username" id="username" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Password" id="password" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Model" id="model" autocomplete="off">
        <input type="text" class="first-inps" placeholder="Vendor" id="vendor" autocomplete="off">
        <div class="chk-postion hide"><label><div class="checker" id="uniform-exclude_construction"><span><input type="checkbox" id="exclude_construction"></span></div> Exclude Constructions</label></div>
        <button class="clear-btn-f" id="btn_delete_cameras">Delete Camera(s)</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.overlapping {
  margin-top: 4px;
  z-index: 1;
  position: relative;
  margin-left: -1px;
}

.form-camera-report {
  width: 80%;
  overflow: hidden;
  height: auto;
  float: left;
  text-align: center;
}

.filter-naming {
  width: 62px;
  padding: 9px 2px;
  height: auto;
  float: left;
  text-align: right;
  font-size: 13px;
}

.camera-inputs {
  width: 954px;
  float: left;
  height: auto;
  overflow: hidden;
  padding: 3px 1px;
}

.first-inps {
  background-color: #eee;
  width: 95px;
  padding: 7px;
  margin-left: 5px;
  border: 0;
  float: left;
}

.clear-btn-f {
  padding: 7px;
  display: inline-block;
  background-color: #428bca;
  float: left;
  color: white;
  border: 0;
  margin-left: 10px;
}

.form-camera-report .chk-postion {
  float: left;
}

.hide {
  display: none !important;
}
</style>