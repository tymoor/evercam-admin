<template>
  <div>
    <div class="row user-filters_css">
      <div class="col-sm-5 col-md-6">
        <form>
          <div class="form-row">
            <div class="col-0.5 search-label">
              <label class="control-label">Search :</label>
            </div>
            <div class="col-2 col-xs-2 col-sm-2 col-md-2">
              <input type="text" v-model="company_name" @keyup="userFilterGlobal" class="form-control" placeholder="Company">
            </div>
            <div class="col-2 col-xs-2 col-sm-2 col-md-2">
              <input type="text" v-model="fullname" @keyup="userFilterGlobal" class="form-control" placeholder="Fullname">
            </div>
            <div class="col-2 col-xs-2 col-sm-2 col-md-2">
              <input type="text" v-model="email" @keyup="userFilterGlobal" class="form-control" placeholder="Email">
            </div>
            <div class="col-0.5 label-top" v-show="showAdvanced">
              <label class="control-label">Cameras Owned <</label>
            </div>
            <div class="col-1" v-show="showAdvanced">
              <input type="text" v-on:keypress="isNumber($event)" v-model="cameras_owned" @keyup="userFilterGlobal" class="form-control" placeholder="Cameras Owned <">
            </div>
            <div class="col-0.5 label-top" v-show="showAdvanced">
              <label class="control-label">Cameras Shared <</label>
            </div>
            <div class="col-1" v-show="showAdvanced">
              <input type="text" v-on:keypress="isNumber($event)" v-model="camera_shares" @keyup="userFilterGlobal" class="form-control" placeholder="Cameras Shared <">
            </div>
          </div>
        </form>
      </div>
      <div class="col-sm-5 col-sm-offset-2 col-md-6 col-md-offset-0" v-show="showAdvanced">
        <form class="form-inline">
            <div class="form-group">
              <label for="inputState">Type :&nbsp;</label>
              <select id="inputState" v-model="payment_method" @change="userFilterGlobal" class="form-control">
                <option value="" selected>All</option>
                <option value="0">Stripe</option>
                <option value="1">Custom</option>
                <option value="2">Construction</option>
                <option value="3">Gardai</option>
                <option value="4">Smart Cities</option>
                <option value="5">Unknown</option>
              </select>
            </div>
            <div class="form-group">
              <label for="inputState">Last Login :&nbsp;</label>
              <select id="inputState" v-model="last_login_at_boolean" @change="userFilterGlobal" class="form-control">
                <option value="true">True</option>
                <option value="false">False</option>
                <option value="whatever" selected="selected">Whatever</option>
              </select>
            </div>
            <div class="form-group">
              <label for="inputState">Remembrance Camera :&nbsp;</label>
              <select id="inputState" v-model="include_erc" @change="userFilterGlobal" class="form-control">
                <option value="true">True</option>
                <option value="false">False</option>
                <option value="whatever" selected="selected">Whatever</option>
              </select>
            </div>
        </form>
      </div>
    </div>
    <div class="row user-filters_css margin-left-1" v-show="showAdvanced">
      <div class="col-sm-5 col-md-6">
        <form>
          <div class="form-row">
            <div class="col-0.5 label-top">
              <label class="control-label">Total Cameras</label>
            </div>
            <div class="col-1">
              <input type="text" v-on:keypress="isNumber($event)" v-model="total_cameras" @keyup="userFilterGlobal" class="form-control" placeholder="Total Cameras">
            </div>
            <div class="col-0.5 label-top">
              <label class="control-label">Created Date Older than</label>
            </div>
            <div class="col-1">
              <input type="text" v-model="created_at_date" @keyup="userFilterGlobal" v-on:keypress="isNumber($event)" class="form-control" placeholder="MTs">
            </div>
            <div class="col-0.5 label-top">
              <label class="control-label">Last Login Date Older than</label>
            </div>
            <div class="col-1">
              <input type="text" v-model="last_login_at_date" @keyup="userFilterGlobal" class="form-control" placeholder="MTs" v-on:keypress="isNumber($event)">
            </div>
          </div>
        </form>
      </div>
      <div class="col-sm-5 col-sm-offset-2 col-md-6 col-md-offset-0">
        <button type="button" v-on:click="onModifyClick" class="btn btn-primary btn-right-margin">Modify</button>
        <modal :usersModify="usersModify" />
        <button type="button" @click="deleteUsers" class="btn btn-danger btn-right-margin">Delete</button>
        <button type="button" @click="resetUserFilter" class="btn btn-primary btn-right-margin">Clear Filter</button>
      </div>
    </div>
  </div>
</template>

<style scoped>

.btn-right-margin {
  margin-right: 5px;
}

.10-margin-left {
  margin-left: 10px;
}

.margin-left-1 {
  margin-left: 1px;
}

.form-group {
  margin-left: 2px;
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

.label-top {
  margin-top: 4px;
}

</style>
<script>
  import Modal from './modify_users';
  import _ from "lodash";
  import axios from "axios";

  export default {
    components: {
      Modal
    },
    props: ["selectedUsers"],
    data () {
      return {
        usersModify: false,
        usersDelete: false,
        company_name: "",
        fullname: "",
        email: "",
        payment_method: "",
        last_login_at_date: "",
        last_login_at_boolean: "whatever",
        created_at_date: "",
        total_cameras: "",
        include_erc: "whatever",
        cameras_owned: "",
        camera_shares: "",
        allParams: {},
        showAdvanced: false
      }
    },
    mounted() {
      this.$events.$on("close-user-modify", eventData => this.onModifyClose(eventData))
      this.$events.$on("users-modify", eventData => this.onModifySave(eventData))

      this.$events.$on("show-advance-filters", eventData => this.showAdvancedFilters(eventData))
    },
    methods: {
      isNumber (evt) {
        evt = (evt) ? evt : window.event;
        var charCode = (evt.which) ? evt.which : evt.keyCode;
        if ((charCode > 31 && (charCode < 48 || charCode > 57))) {
          evt.preventDefault();;
        } else {
          return true;
        }
      },

      showAdvancedFilters(bool) {
        this.showAdvanced = bool;
      },

      userFilterGlobal () {
        this.allParams.company_name = this.company_name
        this.allParams.fullname = this.fullname
        this.allParams.email = this.email
        this.allParams.payment_method = this.payment_method
        this.allParams.last_login_at_boolean = this.last_login_at_boolean
        this.allParams.last_login_at_date =  this.last_login_at_date
        this.allParams.created_at_date = this.created_at_date
        this.allParams.total_cameras = this.total_cameras
        this.allParams.include_erc = this.include_erc
        this.allParams.cameras_owned = this.cameras_owned
        this.allParams.camera_shares = this.camera_shares
        let that = this;
        this.fireFilter(that);
      },

      fireFilter: _.debounce((self) => {
        self.$events.fire('user-filter-set', self.allParams)
      }, 500),

      resetUserFilter () {
        this.company_name = ""
        this.fullname = ""
        this.email = ""
        this.payment_method = ""
        this.last_login_at_boolean = "whatever"
        this.last_login_at_date = ""
        this.created_at_date = ""
        this.total_cameras = ""
        this.include_erc = "whatever"
        this.cameras_owned = ""
        this.camera_shares = ""
        this.$events.fire('user-filter-reset')
      },
      onModifyClick () {
        let self = this

        if (Object.keys(self.selectedUsers).length === 0) {
          this.showWarnMsg({
            title: "Warning",
            message: "At least select one user!"
          });
        } else {
          this.usersModify = true
        }
      },
      onModifyClose(modal) {
        this.usersModify = modal
      },
      onModifySave (params) {
        let self = this
        let ids = ""
        self.selectedUsers.map((user) => {
          if (ids === "") {
            ids += "" + user.id +""
          } else {
            ids += "," + user.id +""
          }
        });

        axios({
          method: 'patch',
          url: `/v1/update_multiple_users`,
          data: {
            ids: ids,
            country: params.country,
            payment_type: params.payment_type
          }
        }).then(response => {
          if (response.status == 200) {
            this.usersModify = false
            this.$events.fire("user-modify-refresh", true)
            this.showSuccessMsg({
              title: "Success",
              message: "Users have been updated!"
            })
          } else {
            this.showErrorMsg({
              title: "Error",
              message: "Something went wrong!"
            });
            this.usersModify = true
          }
        })
      },
      deleteUsers () {
        let self = this
        if (Object.keys(self.selectedUsers).length === 0) {
          this.showWarnMsg({
            title: "Warning",
            message: "At least select one user!"
          });
        } else {
          if (window.confirm("Are you sure you want to delete this event?")) {
            console.log(self.selectedUsers)
            self.selectedUsers.forEach((user) => {

              axios({
                method: 'delete',
                url: `${this.$root.api_url}/v1/users/${user.email}?api_id=${user.api_id}&api_key=${user.api_key}`,
                data: {
                }
              }).then(response => {
                if (response.status == 200) {
                  console.log(response.data)
                } else {
                  console.log(error)
                }
              })
            });
            this.$events.fire("user-modify-refresh", true)
          }
        }
      }
    }
  }
</script>