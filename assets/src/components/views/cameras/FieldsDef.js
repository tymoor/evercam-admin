import moment from "moment"
import accounting from "accounting"

export default [
  {
    name: "checkbox-slot",
    titleClass: "camera-checkbox"
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'last_online_at',
    title: 'Last Online At',
    sortField: 'last_online_at',
    togglable: true
  },
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'camera_link',
    title: 'Onwer',
    sortField: 'fullname',
    togglable: true
  },
  {
    name: 'owner_email',
    title: 'Email',
    sortField: 'owner_email',
    togglable: true
  },
  {
    name: 'payment_method',
    title: 'Type',
    sortField: 'payment_method',
    togglable: true,
    formatter: (value) => {
      return paymentMethod(value)
    }
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'total_share',
    title: 'Shares',
    sortField: 'total_share',
    togglable: true
  },
  {
    name: 'external_host',
    title: 'Camera IP',
    sortField: 'external_host',
    togglable: true
  },
  {
    name: 'external_http_port',
    title: 'HTTP Port',
    sortField: 'external_http_port',
    togglable: true
  },
  {
    name: 'external_rtsp_port',
    title: 'RTSP Port',
    sortField: 'external_rtsp_port',
    togglable: true
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'username',
    togglable: true
  },
  {
    name: 'password',
    title: 'Password',
    sortField: 'password',
    togglable: true
  },
  {
    name: 'mac_address',
    title: 'Mac Address',
    sortField: 'mac_address',
    togglable: true
  },
  {
    name: 'vendor_model_name',
    title: 'Model',
    sortField: 'vendor_model_name',
    togglable: true
  },
  {
    name: 'vendor_name',
    title: 'Vendor',
    sortField: 'vendor_name',
    togglable: true
  },
  {
    name: 'timezone',
    title: 'Timezone',
    sortField: 'timezone',
    togglable: true
  },
  {
    name: 'is_public',
    title: 'Public',
    sortField: 'is_public',
    togglable: true,
    formatter: (value) => {
      return booleans(value)
    }
  },
  {
    name: 'is_online',
    title: 'Online',
    sortField: 'is_online',
    togglable: true,
    formatter: (value) => {
      return booleans(value)
    }
  },
  {
    name: 'cloud_recording_storage_duration',
    title: 'Duration',
    sortField: 'cloud_recording_storage_duration',
    togglable: true
  },
  {
    name: 'is_recording',
    title: 'CR Status',
    sortField: 'is_recording',
    togglable: true
  },
  {
    name: 'last_polled_at',
    title: 'Last Polled At',
    sortField: 'last_polled_at',
    togglable: true,
    visible: false
  }
]

var paymentMethod, booleans;

booleans = (name) => {
  switch (name) {
    case true:
      return "<span class='text-success'> True </span>"
    case false:
      return "<span class='text-danger'> False </span>"
    default:
      return ""
  }
}

paymentMethod = function(name) {
  switch (name) {
    case 0:
      return "Stripe";
    case 1:
      return "Custom";
    case 2:
      return "Construction";
    case 3:
      return "Gardai";
    case 4:
      return "Smart Cities";
    default:
      return "Unknown";
  }
};