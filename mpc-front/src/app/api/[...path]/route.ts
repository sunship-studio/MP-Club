import { NextRequest, NextResponse } from 'next/server';

/**
 * Same-origin proxy to the API.
 *
 * The site and the API sit on different registrable domains, so a session
 * cookie set directly by the API is a third-party cookie — Safari drops those
 * outright. Routing credentialed calls through the site's own origin makes the
 * cookie first-party, so `SameSite=Lax` is enough and every browser keeps it
 * (D16).
 */

const API_ORIGIN =
  process.env.API_ORIGIN ??
  (process.env.NODE_ENV === 'production'
    ? 'https://mp-club-production.up.railway.app'
    : 'http://localhost:3500');

/** Headers that describe the old hop and must not be replayed on the new one. */
const STRIPPED = new Set([
  'host',
  'connection',
  'content-length',
  'accept-encoding',
  'transfer-encoding',
]);

async function forward(request: NextRequest, path: string[]): Promise<NextResponse> {
  const target = new URL(`/web/${path.join('/')}`, API_ORIGIN);
  target.search = request.nextUrl.search;

  const headers = new Headers();
  request.headers.forEach((value, key) => {
    if (!STRIPPED.has(key.toLowerCase())) headers.set(key, value);
  });

  const method = request.method;
  const body =
    method === 'GET' || method === 'HEAD' ? undefined : await request.text();

  let upstream: Response;
  try {
    upstream = await fetch(target, {
      method,
      headers,
      body,
      redirect: 'manual',
      cache: 'no-store',
    });
  } catch (error) {
    console.error('API proxy could not reach the backend:', error);
    return NextResponse.json(
      { error: 'The service is unavailable right now. Please try again.' },
      { status: 502 }
    );
  }

  const response = new NextResponse(await upstream.text(), {
    status: upstream.status,
    statusText: upstream.statusText,
  });

  const contentType = upstream.headers.get('content-type');
  if (contentType) response.headers.set('content-type', contentType);

  // Carry Set-Cookie through verbatim. The backend sets a host-only cookie, so
  // forwarding it here binds it to this site's own origin, which is the whole
  // point of the proxy.
  const setCookie = upstream.headers.getSetCookie?.() ?? [];
  for (const cookie of setCookie) {
    response.headers.append('set-cookie', cookie);
  }

  return response;
}

type Context = { params: Promise<{ path: string[] }> };

export async function GET(request: NextRequest, context: Context) {
  return forward(request, (await context.params).path);
}

export async function POST(request: NextRequest, context: Context) {
  return forward(request, (await context.params).path);
}

export async function PATCH(request: NextRequest, context: Context) {
  return forward(request, (await context.params).path);
}

export async function DELETE(request: NextRequest, context: Context) {
  return forward(request, (await context.params).path);
}
