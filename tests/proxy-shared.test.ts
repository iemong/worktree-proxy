import { describe, expect, it } from 'bun:test';
import { buildUpstreamHttpUrl, buildUpstreamWebSocketUrl } from '../src/proxy-shared';

describe('buildUpstreamHttpUrl', () => {
  it('keeps the hash and query string', () => {
    const base = new URL('http://localhost:4000/base');
    const incoming = new URL('http://proxy.local/path?x=1#hash');
    expect(buildUpstreamHttpUrl(base, incoming)).toBe('http://localhost:4000/base/path?x=1#hash');
  });
});

describe('buildUpstreamWebSocketUrl', () => {
  it('switches protocol and drops hash', () => {
    const base = new URL('https://example.com/base');
    const incoming = new URL('http://proxy.local/ws?token=1#hash');
    expect(buildUpstreamWebSocketUrl(base, incoming)).toBe('wss://example.com/base/ws?token=1');
  });
});
