export default [
  {
    name: 'external_host',
    title: 'Camera IP',
    sortField: 'inserted_at',
    togglable: true
  },
  {
    name: 'external_http_port',
    title: 'HTTP Port',
    sortField: 'recipients',
    togglable: true
  },
  {
    name: 'jpg',
    title: 'Snapshot URL',
    sortField: 'jpg',
    togglable: true
  },
  {
    name: 'is_recording',
    title: 'CR Status',
    sortField: 'is_recording',
    togglable: true,
    formatter: (value) => {
      return HumanizeStatus(value)
    }
  },
  {
    name: 'online',
    title: 'Online',
    sortField: 'online',
    togglable: true,
    formatter: (value) => {
      return HumanizeStatus(value)
    }
  },
  {
    name: 'count',
    title: 'Count',
    sortField: 'count',
    togglable: true
  },
  {
    name: "action-slot",
    title: '',
    titleClass: "action-dc-template"
  },
]

let HumanizeStatus = (value) => {
  if (value > 0) {
    return "<span style='color:green'>Yes</span>"
  } else {
    return "<span style='color:red'>No</span>"
  }
}
