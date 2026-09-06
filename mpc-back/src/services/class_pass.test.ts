/**
 * Term maths and entitlement predicate for fixed-term class passes.
 * Pure logic — no mongo, no HTTP. See docs/specs/class-pass.md D3, D4, D7, D9.
 *
 * Run: npx ts-node src/services/class_pass.test.ts
 */
import assert from 'assert';

import { computeTerm, extendTerm, passCovers } from './class_pass';

let passed = 0;
function check(name: string, cond: boolean) {
  assert.ok(cond, `FAIL: ${name}`);
  console.log('  ✓', name);
  passed++;
}

function throws(name: string, fn: () => unknown) {
  let threw = false;
  try {
    fn();
  } catch {
    threw = true;
  }
  check(name, threw);
}

function pass(overrides: Partial<{ validFromDate: string; validUntilDate: string; revoked: boolean }> = {}) {
  return {
    validFromDate: '2026-09-01',
    validUntilDate: '2026-12-01',
    revoked: false,
    ...overrides,
  };
}

function main() {
  // ---- D3: term is anniversary-inclusive ----

  {
    const term = computeTerm('2026-09-01', 3);
    check('term starts on the purchase day', term.validFromDate === '2026-09-01');
    check('3 months from 2026-09-01 is valid through 2026-12-01', term.validUntilDate === '2026-12-01');
  }

  {
    const term = computeTerm('2026-11-01', 3);
    check('a term crossing new year rolls the year over', term.validUntilDate === '2027-02-01');
  }

  {
    check('1 month from 2026-09-15 is 2026-10-15', computeTerm('2026-09-15', 1).validUntilDate === '2026-10-15');
    check('12 months from 2026-09-15 is 2027-09-15', computeTerm('2026-09-15', 12).validUntilDate === '2027-09-15');
  }

  // ---- D3: month-end clamping ----

  {
    check(
      '2026-08-31 + 3 months clamps to 2026-11-30 (no 31st in November)',
      computeTerm('2026-08-31', 3).validUntilDate === '2026-11-30'
    );
    check(
      '2026-11-30 + 3 months clamps to 2027-02-28 (no 30th in February)',
      computeTerm('2026-11-30', 3).validUntilDate === '2027-02-28'
    );
    check(
      '2027-11-30 + 3 months clamps to 2028-02-29 in a leap year',
      computeTerm('2027-11-30', 3).validUntilDate === '2028-02-29'
    );
    check(
      '2026-01-31 + 1 month clamps to 2026-02-28',
      computeTerm('2026-01-31', 1).validUntilDate === '2026-02-28'
    );
  }

  // ---- D3: the purchase date is trusted as a plain date string ----

  {
    throws('a malformed purchase date is rejected, not coerced', () => computeTerm('01/09/2026', 3));
    throws('an impossible purchase date is rejected', () => computeTerm('2026-02-30', 3));
    throws('a zero-month term is rejected', () => computeTerm('2026-09-01', 0));
    throws('a fractional-month term is rejected', () => computeTerm('2026-09-01', 1.5));
  }

  // ---- D4: entitlement is decided against the class occurrence date ----

  {
    check('a class on the first day of the term is covered', passCovers(pass(), '2026-09-01'));
    check('a class on the last day of the term is covered', passCovers(pass(), '2026-12-01'));
    check('a class mid-term is covered', passCovers(pass(), '2026-10-14'));
    check('a class the day after the term ends is refused', !passCovers(pass(), '2026-12-02'));
    check('a class the day before the term starts is refused', !passCovers(pass(), '2026-08-31'));
  }

  {
    const wintered = pass({ validFromDate: '2026-12-15', validUntilDate: '2027-03-15' });
    check('a term spanning new year covers a January class', passCovers(wintered, '2027-01-04'));
    check('a term spanning new year refuses the following April', !passCovers(wintered, '2027-04-01'));
  }

  // ---- D9: revoked stops entitlement whatever the dates say ----

  {
    check('a revoked pass covers nothing mid-term', !passCovers(pass({ revoked: true }), '2026-10-14'));
  }

  // ---- D15: no date fallback — a missing occurrence date is an error, not a false ----

  {
    throws('a missing occurrence date is rejected', () => passCovers(pass(), undefined as unknown as string));
    throws('a malformed occurrence date is rejected', () => passCovers(pass(), '2026-10-14T00:00:00.000Z'));
  }

  // ---- D7: the stacking check is the same predicate, asked about today ----

  {
    const bought = computeTerm('2026-09-01', 3);
    const held = { ...bought, revoked: false };
    check('a holder still has a live pass on its last day, so rebuying is blocked', passCovers(held, '2026-12-01'));
    check('the day after expiry the holder may buy again', !passCovers(held, '2026-12-02'));
    check('a revoked pass does not block a rebuy', !passCovers({ ...held, revoked: true }, '2026-10-14'));
  }

  // ---- D18: a renewal extends the pass from where it ends ----

  {
    check(
      'one month past a 2026-12-01 end date is 2027-01-01',
      extendTerm('2026-12-01', 1, '2026-11-28') === '2027-01-01'
    );
    check(
      'extending counts from the end date, not the payment date',
      extendTerm('2026-12-01', 1, '2026-11-25') === '2027-01-01'
    );
    check(
      'a three-month product extends by three months',
      extendTerm('2026-12-01', 3, '2026-11-28') === '2027-03-01'
    );
  }

  {
    check(
      'a 31 January end clamps to the last day of February',
      extendTerm('2027-01-31', 1, '2027-01-28') === '2027-02-28'
    );
    check(
      'and to 29 February in a leap year',
      extendTerm('2028-01-31', 1, '2028-01-28') === '2028-02-29'
    );
    check(
      'a 31 March end clamps to 30 April',
      extendTerm('2027-03-31', 1, '2027-03-28') === '2027-04-30'
    );
  }

  {
    // A pass that already lapsed — a failed charge that later succeeded, say.
    // Counting from the stale end date would hand back a pass born expired.
    check(
      'a lapsed pass extends from today, not from its stale end date',
      extendTerm('2026-06-01', 1, '2026-09-04') === '2026-10-04'
    );
    check(
      'a pass extended on its own last day still counts from that day',
      extendTerm('2026-12-01', 1, '2026-12-01') === '2027-01-01'
    );
  }

  {
    throws('extendTerm rejects a malformed end date', () => extendTerm('01/12/2026', 1, '2026-11-28'));
    throws('extendTerm rejects an impossible end date', () => extendTerm('2026-02-30', 1, '2026-01-28'));
    throws('extendTerm rejects a malformed today', () => extendTerm('2026-12-01', 1, 'today'));
    throws('extendTerm rejects zero months', () => extendTerm('2026-12-01', 0, '2026-11-28'));
    throws('extendTerm rejects a fractional term', () => extendTerm('2026-12-01', 1.5, '2026-11-28'));
  }

  console.log(`\nALL ${passed} CHECKS PASSED`);
}

try {
  main();
} catch (e: any) {
  console.error('\n', e.message || e);
  process.exit(1);
}
