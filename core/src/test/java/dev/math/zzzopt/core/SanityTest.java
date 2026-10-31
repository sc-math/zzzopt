package dev.math.zzzopt.core;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

@DisplayName("Verificação básica da execução dos testes")
class SanityTest {
    @Test
    @DisplayName("Deve confirmar que a soma de 1 e 1 resulta em 2")
    void works() {
        assertEquals(2, 1 + 1);
    }
}
