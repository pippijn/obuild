#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * This function implements the Damerau-Levenshtein algorithm to
 * calculate a distance between strings.
 *
 * Basically, it says how many letters need to be swapped, substituted,
 * deleted from, or added to string1, at least, to get string2.
 *
 * The idea is to build a distance matrix for the substrings of both
 * strings. To avoid a large space complexity, only the last three rows
 * are kept in memory (if swaps had the same or higher cost as one deletion
 * plus one insertion, only two rows would be needed).
 *
 * At any stage, "i + 1" denotes the length of the current substring of
 * string1 that the distance is calculated for.
 *
 * row2 holds the current row, row1 the previous row (i.e. for the substring
 * of string1 of length "i"), and row0 the row before that.
 *
 * In other words, at the start of the big loop, row2[j + 1] contains the
 * Damerau-Levenshtein distance between the substring of string1 of length
 * "i" and the substring of string2 of length "j + 1".
 *
 * All the big loop does is determine the partial minimum-cost paths.
 *
 * It does so by calculating the costs of the path ending in characters
 * i (in string1) and j (in string2), respectively, given that the last
 * operation is a substitution, a swap, a deletion, or an insertion.
 */
static int
levenshtein (const char * const string1, const char * const string2)
{
  int len1 = strlen (string1), len2 = strlen (string2);
  int *row0 = (int *) malloc (sizeof (int) * (len2 + 1));
  int *row1 = (int *) malloc (sizeof (int) * (len2 + 1));
  int *row2 = (int *) malloc (sizeof (int) * (len2 + 1));
  int i, j;

  for (j = 0; j <= len2; j++)
    row1[j] = j;
  for (i = 0; i < len1; i++)
    {
      int *dummy;

      row2[0] = i + 1;
      for (j = 0; j < len2; j++)
        {
          /* substitution */
          row2[j + 1] = row1[j] + (string1[i] != string2[j]);
          /* swap */
          if (i > 0 && j > 0 && string1[i - 1] == string2[j] &&
              string1[i] == string2[j - 1] &&
              row2[j + 1] > row0[j - 1] + 1)
            row2[j + 1] = row0[j - 1] + 1;
          /* deletion */
          if (row2[j + 1] > row1[j + 1] + 1)
            row2[j + 1] = row1[j + 1] + 1;
          /* insertion */
          if (row2[j + 1] > row2[j] + 1)
            row2[j + 1] = row2[j] + 1;
        }

      dummy = row0;
      row0 = row1;
      row1 = row2;
      row2 = dummy;
    }

  i = row1[len2];

  return i;
}

int
main (int argc, char *argv[])
{
  int distance;
  size_t len1, len2;
  double len, similarity;

  if (argc < 3)
    return EXIT_FAILURE;

  len1 = strlen (argv[1]);
  len2 = strlen (argv[2]);

  if (len1 == 0 && len2 == 0)
    {
      fputs ("100.00", stdout);
      return EXIT_SUCCESS;
    }
  if (strcmp (argv[1], argv[2]) == 0)
    {
      fputs ("100.00", stdout);
      return EXIT_SUCCESS;
    }
  if ((len1 == 0) != (len2 == 0))
    {
      fputs ("0.00", stdout);
      return EXIT_SUCCESS;
    }
  if (len1 > 10000 || len2 > 10000)
    {
      fputs ("unmeasurable", stdout);
      return EXIT_SUCCESS;
    }

  distance = levenshtein (argv[1], argv[2]);

  len = len1 + len2;
  similarity = (len - distance) * (100 / len);

  printf ("%.2f", similarity > 0 ? similarity : 0);

  return EXIT_SUCCESS;
}
