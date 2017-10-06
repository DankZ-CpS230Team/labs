#define _CRT_SECURE_NO_WARNINGS 
#include <stdio.h>

void hanoi(int disk, int src, int dst, int tmp) {
    if (disk == 1) {
        printf("Move disk 1 from %d to %d\n", src, dst);
    } else {
        hanoi(disk - 1, src, tmp, dst);
        printf("Move disk %d from %d to %d\n", disk, src, dst);
        hanoi(disk - 1, tmp, dst, src);
    }
}

int main() {
    int num_disks;

    printf("How many disks do you want to play with? ");
    if (scanf("%d", &num_disks) != 1) {
        printf("Uh-oh, I couldn't understand that...  No towers of Hanoi for you!\n");
        return 1;
    }

    hanoi(num_disks, 1, 2, 3);

    return 0;
}