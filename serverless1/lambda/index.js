
'use strict';

const moment = require('moment');

exports.handler = async (event, context) => {
    const originURL = process.env.ORIGIN_URL || '*';

    emitLambdaAge();

    // Jumlah SAM squirrels yang ditampilkan di website
    const samCount = 1;

    // Bisa diubah melalui environment variable Lambda
    const samMultiplier = process.env.SAM_MULTIPLIER || 1;

    const totalSAMs = samCount * samMultiplier;

    console.log('The number of SAMs to show: ' + samCount);
    console.log('Multiplier to apply to SAMs: ' + samMultiplier);
    console.log('Total number of SAMs to show: ' + totalSAMs);

    return {
        statusCode: 200,
        body: String(totalSAMs),
        headers: {
            'Content-Type': 'text/plain',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,OPTIONS',
            'Access-Control-Allow-Origin': originURL
        }
    };
};

function emitLambdaAge() {
    const now = moment();
    const lambdaAnnouncement = moment('2014-11-04');

    const daysOld = now.diff(lambdaAnnouncement, 'days');

    console.log('Lambda is ' + daysOld + ' days old!');
}
