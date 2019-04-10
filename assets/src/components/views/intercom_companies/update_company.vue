<template>
  <div v-if="showUpdateCompany">
    <transition name="modal">
      <div class="modal modal-mask" style="display: block">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Update</h4>
            </div>
            <div class="modal-body">
              <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
              <form>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Name</label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" placeholder="Name" v-model="company_name">
                  </div>
                </div>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">LinkedIn URL</label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" placeholder="LinkedIn URL" v-model="linkedIn_URL">
                  </div>
                </div>
              </form>
              <p v-if="errors.length">
                <b>Please correct the following error(s):</b>
                <ul>
                  <li v-for="error in errors">{{ error }}</li>
                </ul>
              </p>
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" type="button" @click="validateFormAndSave($event)">Save</button>
              <button class="btn btn-secondary" type="button" @click="clearForm()">Close</button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>
<style scoped>
.modal-mask {
   position: fixed;
   z-index: 9998;
   top: 0;
   left: 0;
   width: 100%;
   height: 100%;
   background-color: rgba(0, 0, 0, .5);
   display: table;
   transition: opacity .3s ease;
}

.modal-dialog {
  width: 350px;
  margin-top: 114.5px;
}

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
  export default {
    props: ["showUpdateCompany", "companyData"],

    data: () => {
      return {
        company_name: "",
        company_id: "",
        company_exid: "",
        linkedIn_URL: "",
        ajaxWait: false,
        errors: []
      }
    },

    watch: {
      companyData() {
        if (this.companyData != null) {
          this.company_name = this.companyData.name,
          this.company_id = this.companyData.id,
          this.company_exid = this.companyData.exid,
          this.linkedIn_URL = this.companyData.linkedin_url
        }
      }
    },

    methods: {
      validateFormAndSave(e) {

        this.errors = []

        if (this.company_name == "") {
          this.errors.push("Company name cannot be empty.")
        }

        if (this.linkedIn_URL != "" && this.linkedIn_URL != null) {
          if ( /(ftp|http|https):\/\/?(?:www\.)?linkedin.com(\w+:{0,1}\w*@)?(\S+)(:([0-9])+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/.test(this.linkedIn_URL)) {} else {
            this.errors.push("LinkedIn URL is not valid.")
          }
        }

        if (Object.keys(this.errors).length === 0) {
          this.ajaxWait = true
          this.$http.post(`/v1/intercom_companies`, {...{linkedIn_URL: this.linkedIn_URL, company_exid: this.company_exid, company_id: this.company_id, company_name: this.company_name}}).then(response => {

            this.showSuccessMsg({
              title: "Success",
              message: `${this.company_name} has been updated as a Company.`
            });

            this.$events.fire("hide-update-company", {
              company_name: this.company_name,
              company_id: this.company_id,
            })
            this.clearForm()
          }, error => {
            this.error.push(error.body.message)
          });
        }
      },

      clearForm() {
        this.ajaxWait = false
        this.company_name = ""
        this.company_id = ""
        this.company_exid = ""
        this.linkedIn_URL = ""
        this.errors = []
        this.$events.fire("hide-update-company", null)
      }
    }
  }
</script>