import moment from "moment";

export default [
  {
    name: "cameras-list-action",
    title: '',
    width: '70px'
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
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
    title: 'Owner',
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
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: "is_online",
    title: 'Online',
    sortField: 'is_online',
    togglable: true,
    width: '80px',
    formatter: (value) => {
      return booleans(value)
    }
  }
]

var booleans;

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
