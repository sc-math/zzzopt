package dev.math.zzzopt.core.build;

/** Domínio de rank do agente, independente do rank de motor ou disco. */
public enum AgentRank {
    A("A"),
    S("S"),
    I("∞");

    private final String symbol;

    AgentRank(String symbol) {
        this.symbol = symbol;
    }

    public String symbol() {
        return symbol;
    }
}
