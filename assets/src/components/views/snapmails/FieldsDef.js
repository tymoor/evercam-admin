export default [
  {
    name: 'inserted_at',
    title: 'Created At',
    sortField: 'inserted_at',
    togglable: true
  },
  {
    name: 'fullname',
    title: 'User',
    sortField: 'fullname',
    togglable: true
  },
  {
    name: 'cameras',
    title: 'Cameras',
    sortField: 'cameras',
    togglable: true
  },
  {
    name: 'recipients',
    title: 'Recipients',
    sortField: 'recipients',
    togglable: true
  },
  {
    name: 'notify_days',
    title: 'Notify Days',
    togglable: true
  },,
  {
    name: 'notify_time',
    title: 'Notify Time',
    sortField: "notify_time",
    togglable: true
  },
  {
    name: 'timezone',
    title: 'Timezone',
    sortField: 'timezone',
    togglable: true
  },
  {
    name: 'is_paused',
    title: 'Paused',
    sortField: 'is_paused',
    togglable: true,
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
