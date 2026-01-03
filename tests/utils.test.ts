import { describe, expect, it } from 'bun:test';
import { combinePaths } from '../src/utils';

describe('combinePaths', () => {
  it('joins base and request paths', () => {
    expect(combinePaths('/base', '/api')).toBe('/base/api');
  });

  it('handles empty base', () => {
    expect(combinePaths('', '/api')).toBe('/api');
  });

  it('normalizes missing leading slash', () => {
    expect(combinePaths('/base', 'api')).toBe('/base/api');
  });
});
