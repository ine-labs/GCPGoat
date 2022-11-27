import * as Yup from 'yup';
import { useState } from 'react';
import { Link, Stack, TextField, IconButton, InputAdornment, Button, Snackbar } from '@mui/material';
import axios from 'axios';
import { Link as RouterLink, useNavigate } from 'react-router-dom';
import { useFormik, Form, FormikProvider } from 'formik';
import { setUserSession, getToken } from '../AuthService';
// material
// import { Link, Stack, Checkbox, TextField, IconButton, InputAdornment, FormControlLabel } from '@mui/material';
// import { LoadingButton } from '@mui/lab';
// component
import Iconify from '../../../components/Iconify';
import httpService from '../../../common/httpService';

// ----------------------------------------------------------------------

// const registerUrl =
//   "https://108u32xo9b.execute-api.us-east-1.amazonaws.com/data/login";

export default function LoginForm() {
  const navigate = useNavigate();

  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState(null);
  const [success, setSuccess] = useState(false);

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setSuccess(false);
      return;
    }

    setSuccess(false);
  };

  const LoginSchema = Yup.object().shape({
    email: Yup.string().email('Email must be a valid email address').required('Email is required'),
    password: Yup.string().required('Password is required'),
  });

  const formik = useFormik({
    initialValues: {
      email: '',
      password: '',
      // remember: true,
    },
    validationSchema: LoginSchema,
    onSubmit: () => {
      setMessage(null);

      const requestBody = {
        email: getFieldProps('email').value,
        password: getFieldProps('password').value,
      };

      httpService
        .post('/login', requestBody)
        .then((response) => {
          console.log("Login response", response)
          if(response.data.body.token === "" || response.data.body.token === undefined || response.data.body.token === null) {
            setMessage('Invalid Credentials !');
            setSuccess(true);
            return;
          }
          setUserSession(response.data.body.user, response.data.body.token);
          setMessage('Login Successful');
          setSuccess(true);
          if(getToken()) {
            navigate('/dashboard/app', { replace: true })
          } else {
            navigate('/login', { replace: true })
            
          }
          // getToken()?(navigate('/dashboard/app', { replace: true }):null;
        })
        .catch((error) => {
          console.log(error)
          if (error.response.status === 401 || error.response.status === 403) {
            console.error("Login error", error)
            console.log(error.response)
            setMessage(error.response.data.body);
            setSuccess(true);
          } else {
            console.error("Login error", error)
            setMessage('There is something wrong in the backend server');
            setSuccess(true);
          }
        });

    },
  });

  // const { errors, touched, values, isSubmitting, handleSubmit, getFieldProps } = formik;
  const { errors, touched, handleSubmit, getFieldProps } = formik;

  const handleShowPassword = () => {
    setShowPassword((show) => !show);
  };

  return (
    <FormikProvider value={formik}>
      <Form autoComplete="off" noValidate onSubmit={handleSubmit}>
        <Stack spacing={3}>
          <TextField
            fullWidth
            autoComplete="username"
            type="email"
            label="Email address"
            {...getFieldProps('email')}
            error={Boolean(touched.email && errors.email)}
            helperText={touched.email && errors.email}
          />

          <TextField
            fullWidth
            autoComplete="current-password"
            type={showPassword ? 'text' : 'password'}
            label="Password"
            {...getFieldProps('password')}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton onClick={handleShowPassword} edge="end">
                    <Iconify icon={showPassword ? 'eva:eye-fill' : 'eva:eye-off-fill'} />
                  </IconButton>
                </InputAdornment>
              ),
            }}
            error={Boolean(touched.password && errors.password)}
            helperText={touched.password && errors.password}
          />
        </Stack>

        <Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ my: 2 }}>
          {/* <FormControlLabel
            control={<Checkbox {...getFieldProps('remember')} checked={values.remember} />}
            label="Remember me"
          /> */}

          <Link component={RouterLink} variant="subtitle2" to="/reset-password" underline="hover">
            Forgot password?
          </Link>
        </Stack>

        {/* <LoadingButton fullWidth size="large" type="submit" variant="contained" loading={isSubmitting}>
          Login
        </LoadingButton> */}

        <Button fullWidth size="large" type="submit" variant="contained">
          Login
        </Button>
        <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
      </Form>
    </FormikProvider>
  );
}
