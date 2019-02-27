export default [
  {
    name: 'exid',
    title: 'Camera',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'fullname',
    title: 'Requested By',
    sortField: 'fullname',
    togglable: true
  },
  {
    name: 'title',
    title: 'Title',
    sortField: 'title',
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
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true,
    formatter: (value) => {
      return statusCheck(value)
    }
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'duration',
    title: 'Duration',
    sortField: 'duration',
    togglable: true,
    formatter: (value) => {
      return secondsTimeSpanToHMS(value)
    }
  },
  {
    name: 'public',
    title: 'Public',
    sortField: 'public',
    togglable: true,
    formatter: (value) => {
      return booleans(value)
    }
  }
]

var booleans, statusCheck, secondsTimeSpanToHMS;

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

secondsTimeSpanToHMS = function(s) {
  var h, m;
  h = Math.floor(s / 3600);
  s -= h * 3600;
  m = Math.floor(s / 60);
  s -= m * 60;
  return h + ':' + (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);
};