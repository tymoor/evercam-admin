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
    title: '# No',
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
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: 'dec',
    title: 'D',
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
