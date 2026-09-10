/**
 * Cloudflare Worker: Supabase Reverse Proxy with WebSocket & OAuth Support
 * Project: Infinity Wellness
 * Target Supabase Project: sxbwrwvgmlklpojmokye.supabase.co
 * 
 * Instructions:
 * 1. Go to Cloudflare Dashboard -> Workers & Pages -> 'supabase-proxy-infinity-wellness'
 * 2. Click 'Edit code' (Quick Edit)
 * 3. Replace all existing starter code (the default 'Hello World') with this script
 * 4. Click 'Deploy'
 */

const UPSTREAM_HOST = "sxbwrwvgmlklpojmokye.supabase.co";

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const workerHost = url.host;

    // 1. Handle CORS preflight for mobile and web requests
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "*",
          "Access-Control-Max-Age": "86400",
        },
      });
    }

    // 2. Build upstream Supabase URL
    const upstreamUrl = new URL(request.url);
    upstreamUrl.host = UPSTREAM_HOST;
    upstreamUrl.protocol = "https:";
    upstreamUrl.port = "443";

    // 3. Prepare headers for upstream
    const forwardHeaders = new Headers(request.headers);
    forwardHeaders.set("Host", UPSTREAM_HOST);

    // If Origin is present, point to upstream to prevent CORS rejection from Supabase
    if (forwardHeaders.has("Origin")) {
      forwardHeaders.set("Origin", `https://${UPSTREAM_HOST}`);
    }

    // Forward client IP
    const clientIp = request.headers.get("CF-Connecting-IP");
    if (clientIp) {
      forwardHeaders.set("X-Forwarded-For", clientIp);
      forwardHeaders.set("X-Real-IP", clientIp);
    }

    // 4. Supabase Realtime WebSocket support
    if (request.headers.get("Upgrade")?.toLowerCase() === "websocket") {
      return fetch(upstreamUrl.toString(), {
        method: request.method,
        headers: forwardHeaders,
      });
    }

    // 5. Forward HTTP request to Supabase
    const init = {
      method: request.method,
      headers: forwardHeaders,
      redirect: "manual", // Preserve 301/302 redirects for OAuth flow
    };

    if (request.method !== "GET" && request.method !== "HEAD") {
      init.body = request.body;
    }

    try {
      const response = await fetch(upstreamUrl.toString(), init);

      // Clone response headers
      const responseHeaders = new Headers(response.headers);

      // 6. Rewrite upstream hostname in Location redirects if redirecting to Supabase directly
      // Only rewrite if Supabase redirects to its own domain (e.g. auth redirects, password resets)
      // DO NOT rewrite redirect_uri parameters inside third-party OAuth URLs (e.g. accounts.google.com)
      // because OAuth providers (Google) strictly require the redirect_uri in the token exchange to match
      // the redirect_uri used during the authorization request.
      const location = responseHeaders.get("Location");
      if (location) {
        if (location.startsWith(`https://${UPSTREAM_HOST}`) || location.startsWith(`http://${UPSTREAM_HOST}`)) {
          const rewrittenLocation = location
            .replace(`https://${UPSTREAM_HOST}`, `https://${workerHost}`)
            .replace(`http://${UPSTREAM_HOST}`, `https://${workerHost}`);
          responseHeaders.set("Location", rewrittenLocation);
        }
      }

      // 7. Inject permissive CORS headers
      responseHeaders.set("Access-Control-Allow-Origin", "*");
      responseHeaders.set("Access-Control-Allow-Headers", "*");
      responseHeaders.set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");

      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: responseHeaders,
      });
    } catch (err) {
      return new Response(
        JSON.stringify({ error: "Supabase proxy upstream error", details: err.message }),
        {
          status: 502,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }
  },
};
