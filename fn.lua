function mixColor(a,b,r1)
  local r2 = 1-r1
  return {
    a[1]*r1 + b[1]*r2,
    a[2]*r1 + b[2]*r2,
    a[3]*r1 + b[3]*r2,
    (a[4] or 1)*r1 + (b[4] or 1)*r2,
  }
end