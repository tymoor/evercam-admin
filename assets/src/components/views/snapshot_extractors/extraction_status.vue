<template>
  <div>
    <div v-if="showModal">
      <transition name="modal">
       <div class="modal modal-mask" style="display: block;">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h3 class="modal-title">
                Extraction Status
              </h3>
            </div>
            <div class="modal-body">
              <table class="table table-responsive-sm table-bordered">
                 <thead>
                    <tr>
                       <th>Camera Name</th>
                       <th>Jpegs Extracted</th>
                       <th>Status</th>
                    </tr>
                 </thead>
                 <tbody>
                    <tr>
                       <td>{{ results.name }}</td>
                       <td>{{ results.results.jpegs }}</td>
                       <td>
                          <span v-if="results.results.status == 'up'" class="badge badge-success">Active</span>
                          <span v-if="results.results.status == 'down'" class="badge badge-secondary">Inactive</span>
                       </td>
                    </tr>
                 </tbody>
              </table>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-primary" @click="hideModal()"> Close </button>
            </div>
          </div>
        </div>
      </div>
      </transition>
    </div>
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
  width: 25%;
  max-width: 100%;
  margin-top: 114.5px;
}

modal-dialog-1 {
  width: 200px;
  max-width: 100%;
  margin-top: 114.5px;
}

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
  export default {
    props: ["results", "showModal"],
    data: () => {
      return {
      }
    },

    methods: {
      hideModal () {
        this.$events.fire("close-extraction-status-modal", false)
      }
    }
  }
</script>
