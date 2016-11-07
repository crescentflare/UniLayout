package com.crescentflare.unilayoutexample.reusingcontainer;

/**
 * Reusing container example: reusable item
 * An item to show in the recycler view
 */
public class ReusableItem
{
    // ---
    // Item type enum
    // ---

    public enum Type
    {
        Unknown,
        Section,
        Item,
        TopDivider,
        BottomDivider
    }


    // ---
    // Members
    // ---

    private Type type = Type.Unknown;
    private String title = "";
    private String additional = "";
    private String value = "";


    // ---
    // Initialization
    // ---

    public ReusableItem(Type type)
    {
        this(type, "", "", "");
    }

    public ReusableItem(Type type, String title)
    {
        this(type, title, "", "");
    }

    public ReusableItem(Type type, String title, String additional, String value)
    {
        this.type = type;
        this.title = title;
        this.additional = additional;
        this.value = value;
    }


    // ---
    // Generated code
    // ---

    public Type getType()
    {
        return type;
    }

    public void setType(Type type)
    {
        this.type = type;
    }

    public String getTitle()
    {
        return title;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getAdditional()
    {
        return additional;
    }

    public void setAdditional(String additional)
    {
        this.additional = additional;
    }

    public String getValue()
    {
        return value;
    }

    public void setValue(String value)
    {
        this.value = value;
    }
}
