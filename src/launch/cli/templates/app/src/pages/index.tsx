import React from 'react';
import axios from 'axios'
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
  await axios.get('http://localhost:3001')
    .then((res: HomeResponse) => {
      if (res.status === 200) {
        props.message = res.data.message
      } else {
        props.message = 'Some error has occurred.'
      }
    })
    .catch(err => {
      const fgRed = "\x1b[31m"
      const reset = "\x1b[0m"
      const bright = "\x1b[1m"
      const bgRed = "\x1b[41m"
      const fgWhite = "\x1b[37m"
      console.error(
        `\n ${fgRed}▸${reset} ${bright}${bgRed}${fgWhite} ${err.message} ${reset}`,
      );
    })
  return {
    props,
  };
}