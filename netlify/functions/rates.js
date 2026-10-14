// Netlify Serverless Function: GET /api/rates?base=USD
// Keeps EXCHANGE_RATE_API_KEY / API_KEY 100% server-side so it is never exposed
// in main.dart.js or browser network requests.

const cache = new Map(); // base -> { data, fetchedAt }
const TTL_MS = 60 * 60 * 1000; // 1 hour server-side cache

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 204,
      headers: corsHeaders(),
      body: '',
    };
  }

  if (event.httpMethod !== 'GET') {
    return jsonResponse(405, { result: 'error', error: 'Method not allowed' });
  }

  const params = event.queryStringParameters || {};
  const base = (params.base || 'USD').toUpperCase().replace(/[^A-Z]/g, '');

  if (base.length !== 3) {
    return jsonResponse(400, { result: 'error', error: 'Invalid base currency code' });
  }

  // Serve from in-memory cache if fresh
  const cached = cache.get(base);
  if (cached && Date.now() - cached.fetchedAt < TTL_MS) {
    return jsonResponse(200, cached.data, true);
  }

  try {
    const data = await fetchRatesFromUpstream(base);
    cache.set(base, { data, fetchedAt: Date.now() });
    return jsonResponse(200, data, false);
  } catch (err) {
    // Return stale cache if upstream fails
    if (cached) {
      return jsonResponse(200, cached.data, true);
    }
    return jsonResponse(502, {
      result: 'error',
      error: 'Failed to fetch exchange rates',
    });
  }
};

async function fetchRatesFromUpstream(base) {
  const apiKey = process.env.EXCHANGE_RATE_API_KEY || process.env.API_KEY;

  // 1. Try authenticated v6 endpoint if server-side key is configured in Netlify
  if (apiKey && apiKey !== 'YOUR_API_KEY_HERE') {
    try {
      const keyedUrl = `https://v6.exchangerate-api.com/v6/${apiKey}/latest/${base}`;
      const res = await fetch(keyedUrl);
      if (res.ok) {
        const json = await res.json();
        if (json && json.result === 'success' && json.conversion_rates) {
          return {
            result: 'success',
            base_code: json.base_code || base,
            time_last_update_unix: json.time_last_update_unix,
            time_last_update_utc: json.time_last_update_utc,
            time_next_update_unix: json.time_next_update_unix,
            time_next_update_utc: json.time_next_update_utc,
            conversion_rates: json.conversion_rates,
          };
        }
      }
    } catch (_) {
      // Fall through to open v6 endpoint
    }
  }

  // 2. Fallback to ExchangeRate-API official open v6 endpoint
  const openUrl = `https://open.er-api.com/v6/latest/${base}`;
  const res = await fetch(openUrl);
  if (!res.ok) {
    throw new Error(`Upstream error: ${res.status}`);
  }
  const json = await res.json();
  const rates = json.conversion_rates || json.rates;
  if (json.result !== 'success' || !rates) {
    throw new Error('Unexpected response payload');
  }

  return {
    result: 'success',
    base_code: json.base_code || base,
    time_last_update_unix: json.time_last_update_unix,
    time_last_update_utc: json.time_last_update_utc,
    time_next_update_unix: json.time_next_update_unix,
    time_next_update_utc: json.time_next_update_utc,
    conversion_rates: rates,
  };
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}

function jsonResponse(statusCode, bodyObj, isCacheHit = false) {
  return {
    statusCode,
    headers: {
      ...corsHeaders(),
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': statusCode === 200
          ? 'public, max-age=3600, s-maxage=3600'
          : 'no-store',
      'X-Rates-Cache': isCacheHit ? 'HIT' : 'MISS',
    },
    body: JSON.stringify(bodyObj),
  };
}
