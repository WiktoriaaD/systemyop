

class Slab:
    def __init__(self, start_addr, obj_size, obj_count):
        self.start_addr = start_addr
        self.obj_size = obj_size
        self.obj_count = obj_count
        self.bitmap = [0] * obj_count  # 0 = wolne, 1 = zajęte

    def alloc(self):
        if self.is_full():
            return None
        for i in range(self.obj_count):
            if self.bitmap[i] == 0:
                self.bitmap[i] = 1
                return self.start_addr + (i * self.obj_size)
        return None

    def free(self, addr):
        offset = addr - self.start_addr
        index = offset // self.obj_size
        self.bitmap[index] = 0

    def is_full(self):
        return 0 not in self.bitmap

    def owns_address(self, addr):
        end_addr = self.start_addr + (self.obj_size * self.obj_count)
        return self.start_addr <= addr < end_addr


class SlabCache:
    def __init__(self, obj_size, objects_per_slab):
        self.obj_size = obj_size
        self.objects_per_slab = objects_per_slab
        self.slabs = []
        self.next_slab_addr = 1000  #symulowany start pamieci

    def alloc(self):
        #szukanie w istniejacych
        for slab in self.slabs:
            if not slab.is_full():
                return slab.alloc()
        
        #tworzenie nowegu slab przy braku miejsca
        print(f"Brak miejsca. Tworzenie nowego SLab")
        new_slab = Slab(self.next_slab_addr, self.obj_size, self.objects_per_slab)
        self.slabs.append(new_slab)
        self.next_slab_addr += (self.obj_size * self.objects_per_slab)
        
        return new_slab.alloc()

    def free(self, addr):
        for slab in self.slabs:
            if slab.owns_address(addr):
                slab.free(addr)
                print(f"Zwolniono: {addr}")
                return
            else:
                print("Nie znaleziono.")


def main():
    cache = SlabCache(obj_size=32, objects_per_slab=3)

    print("\n1. Alokacja 3 obiektów (zapelnia pierwszy Slab)")
    a = cache.alloc()
    print(f"   Zalokowano: {a}")
    b = cache.alloc()
    print(f"   Zalokowano: {b}")
    c = cache.alloc()
    print(f"   Zalokowano: {c}")

    print("\nAlokacja 4. obiektu (musi utworzyc NOWY Slab)")
    d = cache.alloc()
    print(f"   Zalokowano: {d}")

    print("\nZwalnianie.")
    cache.free(b)

    print("\nPonowna alokacja")
    b_new = cache.alloc()
    print(f"Zalokowano: {b_new}")

if __name__ == "__main__":
    main()
