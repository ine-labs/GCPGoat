// ----------------------------------------------------------------------

import { getUser } from '../sections/auth/AuthService';

const user = getUser();

const displayName = user !== 'undefined' && user ? user.name : '';
const email = user !== 'undefined' && user ? user.email : '';

// console.log("ACCOUNT", displayName, email)

const account = {
  // displayName: 'Sanjeev Mahunta',
  // email: 'smahunta@ine.com',
  displayName,
  email,
  photoURL: '/static/mock-images/avatars/avatar_default.jpg',
};

export default account;
