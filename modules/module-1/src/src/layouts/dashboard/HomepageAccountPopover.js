import { useRef, useState } from 'react';
import { Link as RouterLink, useNavigate } from 'react-router-dom';
// @mui
import { alpha } from '@mui/material/styles';
import { Box, Divider, Typography, Stack, MenuItem, Avatar, IconButton } from '@mui/material';
// components
import MenuPopover from '../../components/MenuPopover';
// mocks_
import account from '../../_mock/account';
import { resetUserSession, getUser } from '../../sections/auth/AuthService';


// ----------------------------------------------------------------------

const MENU_OPTIONS = [
  {
    label: 'Login',
    icon: 'eva:home-fill',
    linkTo: '/login',
  },
  {
    label: 'Dashboard',
    icon: 'eva:person-fill',
    linkTo: '/dashboard/app',
  },
  // {
  //   label: 'Blogposts',
  //   icon: 'eva:settings-2-fill',
  //   linkTo: '/home',
  // },
];

// ----------------------------------------------------------------------
// const user = getUser();
// const displayName = user !== 'undefined' && user ? user.name : '';
// const email = user !== 'undefined' && user ? user.email : '';

// const account = {
  //   // displayName: 'Sanjeev Mahunta',
  //   // email: 'smahunta@ine.com',
  //   displayName,
  //   email,
  //   photoURL: '/static/mock-images/avatars/avatar_default.jpg',
  // };
  
  export default function HomepageAccountPopover() {
    
    const user = getUser();
    
    const displayName = user !== 'undefined' && user ? user.name : '';
    const email = user !== 'undefined' && user ? user.email : '';
    
    const anchorRef = useRef(null);
    const navigate = useNavigate();
    
    const [open, setOpen] = useState(null);
    
    const handleOpen = (event) => {
      setOpen(event.currentTarget);
    };

  const logoutHandler=() =>{
    resetUserSession();
    navigate('/login');
  }
  
  const handleClose = () => {
    setOpen(null);
  };

  return (
    <>
      <IconButton
        ref={anchorRef}
        onClick={handleOpen}
        sx={{
          p: 0,
          ...(open && {
            '&:before': {
              zIndex: 1,
              content: "''",
              // width: '100%',
              // height: '100%',
              borderRadius: '50%',
              position: 'absolute',
              bgcolor: (theme) => alpha(theme.palette.grey[900], 0.8),
            },
          }),
        }}
      >
        <Avatar src={account.photoURL} alt="photoURL" />
      </IconButton>

      <MenuPopover
        open={Boolean(open)}
        anchorEl={open}
        onClose={handleClose}
        sx={{
          p: 0,
          mt: 1.5,
          ml: 0.75,
          '& .MuiMenuItem-root': {
            typography: 'body2',
            borderRadius: 0.75,
          },
        }}
      >
        <Box sx={{ my: 1.5, px: 2.5 }}>
          <Typography variant="subtitle2" noWrap>
            {displayName}
          </Typography>
          <Typography variant="body2" sx={{ color: 'text.secondary' }} noWrap>
            {email}
          </Typography>
        </Box>

        <Divider sx={{ borderStyle: 'dashed' }} />

        <Stack sx={{ p: 1 }}>
          {MENU_OPTIONS.map((option) => (
            <MenuItem key={option.label} to={option.linkTo} component={RouterLink} onClick={handleClose}>
              {option.label}
            </MenuItem>
          ))}
        </Stack>
      </MenuPopover>
    </>
  );
}
