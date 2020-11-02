import React from 'react';
import api from '../services/Api'
import HelloLaunch from '../components/HelloLaunch';
import ServerResponse from '../types/ServerResponse';

const Home = ({ message }: { message: string }) => (
  <HelloLaunch message={message} />
);

export default Home;

interface HomeResponse extends ServerResponse {
  data: {
    message: string
  }
}

export async function getServerSideProps() {
  const props = { message: '' };
  await api.get('/')
    .then((res: HomeResponse) => {
      if (res.status === 200) {
        props.message = res.data.message
      } else {
        props.message = 'Some error has occurred.'
      }
    })
  return {
    props,
  };
}