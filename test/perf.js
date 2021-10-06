const keyLength = 20;

export default async function perf(name, run) {
  console.log(name + '\n');

  let console_log = console.log;
  let console_error = console.error;
  console.log = () => {};
  console.error = () => {};

  let startTime = {}; // key: startTime
  let runTimes = {}; // key: [(endTime - startTime)]
  function start(key) {
    startTime[key] = performance.now();
    return () => stop(key);
  }
  function stop(key) {
    let end = performance.now();
    let start_ = startTime[key];
    startTime[key] = undefined;
    if (start_ === undefined) throw Error('running stop with no start defined');
    let times = runTimes[key];
    if (times === undefined) {
      runTimes[key] = times = [];
    }
    times.push(end - start_);
  }

  console_log('First run after page load (varies between runs!):');
  await run(start, stop);
  for (let key in runTimes) {
    console_log(
      `${(key + ':').padEnd(keyLength)} ${runTimes[key][0].toFixed(2)} ms`
    );
  }
  console_log('');

  let n = 50;
  runTimes = {};
  let noop = _ => () => {};
  console_log('Average of 50x after warm-up of 50x:');
  for (let i = 0; i < 2 * n; i++) {
    if (i === 2 * n - 1) {
      console.log = console_log;
      console.error = console_error;
    }
    if (i < n) await run(noop, noop);
    else await run(start, stop);
  }
  for (let key in runTimes) {
    console_log(
      `${(key + ':').padEnd(keyLength)} ${printMeanStd(runTimes[key])} ms`
    );
  }
  console.log('');
}

function meanStd(numbers) {
  let sum = 0;
  let sumSquares = 0;
  for (let i of numbers) {
    sum += i;
    sumSquares += i ** 2;
  }
  let n = numbers.length;
  let mean = sum / n;
  let std = Math.sqrt(((sumSquares / n - mean ** 2) * n) / (n - 1));
  return [mean, std];
}

function printMeanStd(numbers) {
  let [mean, std] = meanStd(numbers);
  return `${mean.toFixed(2)} ± ${std.toFixed(2)}`;
}
