export default [
  {
    name: "extraction-status",
    title: "",
    titleClass: "center aligned",
    dataClass: "center aligned delete-extraction"
  },
  {
    name: "delete-extraction",
    title: "",
    titleClass: "center aligned",
    dataClass: "center aligned delete-extraction"
  },
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
    togglable: true,
    formatter: (value) => {
      return secondsTimeSpanToHMS(value)
    }
  },
  {
    name: 'status',
    title: 'Status',
    togglable: true,
    sortField: 'status',
    formatter: (value) => {
      return statusCheck(value)
    }
  },
  {
    name: 'notes',
    title: 'Notes',
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

var checkNature, statusCheck, secondsTimeSpanToHMS;

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
      return "Processing"
    case 12:
      return "Completed"
    case 21:
      return "Processing"
    case 22:
      return "Completed"
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