let i = gets("> ", false).to_n()
let o = 0
let j = 0

loop {
  (i - 1 - o).n(->write(" "));
  (i + o).n(->write("* "));
  write("\n");

  if j < i - 1 {
    o += 1
  } else {
    o -= 1
  }

  if o < 0 {
    break
  }

  j += 1
}

/*
 * Codegolfed for http://codegolf.stackexchange.com/questions/104604/could-you-make-me-a-hexagon-please
 *
 * let i="".promptn()let o=0let j=0loop{(i-1-o).n(->write(" "));(i+o).n(->write("* "))write("\n")o+=j<i-1?1:-1if o<0{break}j+=1}
 *
 * */
