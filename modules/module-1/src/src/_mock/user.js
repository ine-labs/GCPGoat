// import React, {useEffect} from 'react';
// import axios from 'axios';
import { faker } from '@faker-js/faker';
import { sample } from 'lodash';

// ----------------------------------------------------------------------

const users = [...Array(24)].map((_, index) => ({
  id: faker.datatype.uuid(),
  avatarUrl: `/static/mock-images/avatars/avatar_${index + 1}.jpg`,
  name: faker.name.findName(),
  company: faker.company.companyName(),
  isVerified: faker.datatype.boolean(),
  status: sample(['active', 'banned']),
  role: sample([
    'Leader',
    'Hr Manager',
    'UI Designer',
    'UX Designer',
    'UI/UX Designer',
    'Project Manager',
    'Backend Developer',
    'Full Stack Designer',
    'Front End Developer',
    'Full Stack Developer',
  ]),
}));

// const users = [
//   {
//     company: "Apple",
//     id: "1",
//     isVerified: false,
//     name: "Sanjeev Mahunta",
//     role: "Software Engineer",
//     status: "active"
//   },
//   {
//     company: "Microsoft",
//     id: "2",
//     isVerified: false,
//     name: "Sansa Stark",
//     role: "Data Scientist",
//     status: "banned"
//   },
//   {
//     company: "Facebook",
//     id: "3",
//     isVerified: true,
//     name: "Jon Snow",
//     role: "Nangdoosh",
//     status: "active"
//   },
// ]
export default users;
