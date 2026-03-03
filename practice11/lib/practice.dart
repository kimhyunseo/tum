class Solution {
  int findClosest(int x, int y, int z) {
    int a = (z - x).abs();
    int b = (z - y).abs();

    print(a);
    print(b);

    if (a < b) {
      return 1;
    } else if (a > b) {
      return 2;
    } else {
      return 0;
    }
  }
}

void main() {
  int x = 2;
  int y = 7;
  int z = 4;

  Solution s = Solution();
  print(s.findClosest(x, y, z));
}
