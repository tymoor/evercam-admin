export default [
  {
    name: 'inserted_at',
    title: 'Created At',
    sortField: 'inserted_at',
    togglable: true
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'camera_link',
    title: 'Camera',
    sortField: 'camera_name',
    togglable: true
  },
  {
    name: 'name_link',
    title: 'Requester',
    sortField: 'fullname',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true,
    formatter: (value) => {
      return statusCheck(value)
    }
  },
  {
    name: 'embed_code_slot',
    title: 'Embed Code',
    togglable: true
  },
  {
    name: 'download',
    title: 'Downlaod',
    togglable: true
  }
]

var statusCheck;

statusCheck = (status) => {
  switch (status) {
    case 0:
      return "Pending"
    case 1:
      return "Processing"
    case 2:
      return "Completed"
    case 3:
      return "Failed"
    default:
      return ""
  }
}
