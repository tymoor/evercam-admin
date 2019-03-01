export default [
  {
    name: 'id',
    title: 'ID',
    sortField: 'id',
    togglable: true
  },
  {
    name: 'camera',
    title: 'Camera',
    sortField: 'camera',
    togglable: true
  },
  {
    name: 'from_date',
    title: 'From Date',
    sortField: 'from_date',
    togglable: true
  },
  {
    name: 'to_date',
    title: 'To Date',
    sortField: 'to_date',
    togglable: true
  },
  {
    name: 'interval',
    title: 'Interval',
    sortField: 'interval',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    togglable: true,
    formatter: (value) => {
      return statusCheck(value)
    }
  },
  {
    name: 'notes',
    title: 'Notes',
    sortField: 'notes',
    togglable: true
  },
  {
    name: 'status',
    title: 'Extraction',
    togglable: true,
    formatter: (value) => {
      return checkNature(value)
    }
  },
  {
    name: 'requestor',
    title: 'Requestor',
    sortField: 'requestor',
    togglable: true
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true
  }
]

var checkNature, statusCheck;

checkNature = (name) => {
  if (parseInt(name) < 9) {
    return "Cloud"
  } else {
    return "Local"
  }
}

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
    case 11:
      return "Failed"
    case 12:
      return "Completed"
    default:
      return ""
  }
}
