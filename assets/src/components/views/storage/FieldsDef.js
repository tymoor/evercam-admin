import moment from "moment";

export default [
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'camera_name',
    title: 'Camera',
    sortField: 'camera_name',
    togglable: true
  },
  {
    name: 'total_months',
    title: '# Recording Months',
    sortField: 'total_months',
    togglable: true
  },
  {
    name: 'oldest_snapshot_date',
    title: "Oldest Snapshot",
    titleClass: "snapshot_date",
    formatter: (value) => {
      return dateFormat(value)
    }
  },
  {
    name: 'latest_snapshot_date',
    title: "Latest Snapshot",
    titleClass: "snapshot_date",
    formatter: (value) => {
      return dateFormat(value)
    }
  },
  {
    name: 'jan',
    title: 'J',
    sortField: "jan",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'feb',
    title: 'F',
    sortField: "feb",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'mar',
    title: 'M',
    sortField: "mar",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'apr',
    title: 'A',
    sortField: "apr",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'may',
    title: 'M',
    sortField: "may",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'jun',
    title: 'J',
    sortField: "jun",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'jul',
    title: 'J',
    sortField: "jul",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'aug',
    title: 'A',
    sortField: "aug",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'sep',
    title: 'S',
    sortField: "sep",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'oct',
    title: 'O',
    sortField: "oct",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'nov',
    title: 'N',
    sortField: "nov",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'dec',
    title: 'D',
    sortField: "dec",
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
]

var boxStoragePresence;

boxStoragePresence = function(value) {
  if (value === 1) {
    return `<div class="input-color">
               <div class="color-box" style="background-color: #000000;"></div>
            </div>
            `;
  } else {
    return "";
  }
};

var dateFormat = (value) => {
  return moment(value).format("DD MMM YYYY h:mm A");
}
