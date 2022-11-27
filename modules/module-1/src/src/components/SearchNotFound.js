import PropTypes from 'prop-types';
// material
import { Paper, Typography } from '@mui/material';

// ----------------------------------------------------------------------

SearchNotFound.propTypes = {
  searchQuery: PropTypes.string,
};

export default function SearchNotFound({ searchQuery = '', ...other }) {
  return (
    <Paper {...other}>
      <p style={{ textAlign: 'center' }}>Results for <strong dangerouslySetInnerHTML={{ __html: searchQuery }}/></p>
    </Paper>
  );
}