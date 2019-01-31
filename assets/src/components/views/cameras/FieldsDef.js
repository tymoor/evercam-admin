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
    name: 'last_polled_at',
    title: 'Last Online At',
    sortField: 'last_polled_at',
    togglable: true
  },
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'owner',
    title: 'Owner',
    sortField: 'owner',
    togglable: true
  },
  {
    name: 'email',
    title: 'Email',
    sortField: 'email',
    togglable: true
  },
  {
    name: 'type',
    title: 'Type',
    sortField: 'type',
    togglable: true
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'shares',
    title: 'Shares',
    sortField: 'shares',
    togglable: true
  },
  {
    name: 'camera_ip',
    title: 'Camera IP',
    sortField: 'camera_ip',
    togglable: true
  },
  {
    name: 'http_port',
    title: 'HTTP Port',
    sortField: 'http_port',
    togglable: true
  },
  {
    name: 'rtsp_port',
    title: 'RTSP Port',
    sortField: 'rtsp_port',
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
    name: 'model',
    title: 'Model',
    sortField: 'model',
    togglable: true
  },
  {
    name: 'vendor',
    title: 'Vendor',
    sortField: 'vendor',
    togglable: true
  },
  {
    name: 'timezone',
    title: 'Timezone',
    sortField: 'timezone',
    togglable: true
  },
  {
    name: 'public',
    title: 'Public',
    sortField: 'public',
    togglable: true
  },
  {
    name: 'online',
    title: 'Online',
    sortField: 'online',
    togglable: true
  },
  {
    name: 'duration',
    title: 'Duration',
    sortField: 'duration',
    togglable: true
  },
  {
    name: 'cr_status',
    title: 'CR Status',
    sortField: 'cr_status',
    togglable: true
  }
]

var paymentMethod;

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