package com.crescentflare.unilayoutexample.reusingcontainer;

import android.view.View;

import com.crescentflare.unilayout.containers.UniReusingContainer;
import com.crescentflare.unilayout.views.UniReusableView;
import com.crescentflare.unilayoutexample.R;
import com.crescentflare.unilayoutexample.reusingcontainer.views.SectionDividerView;
import com.crescentflare.unilayoutexample.reusingcontainer.views.ItemView;
import com.crescentflare.unilayoutexample.reusingcontainer.views.SectionView;
import com.crescentflare.unilayoutexample.reusingcontainer.views.UnderItemView;

import java.util.ArrayList;
import java.util.List;

/**
 * Reusing container example: adapter
 * Provides display of reusable items
 */
public class ReusingContainerAdapter extends UniReusingContainer.Adapter
{
    // ---
    // Members
    // ---

    private List<ReusableItem> items = new ArrayList<>();


    // ---
    // Clear/add items
    // ---

    public void removeItems()
    {
        items.clear();
        notifyDataSetChanged();
    }

    public void addItem(ReusableItem item)
    {
        items.add(item);
        notifyDataSetChanged();
    }


    // ---
    // Internal item access
    // ---

    @Override
    public int getItemCount()
    {
        return items.size();
    }

    @Override
    public String getItemViewType(int itemPosition)
    {
        ReusableItem item = items.get(itemPosition);
        if (item.getType() == null)
        {
            return super.getItemViewType(itemPosition);
        }
        return item.getType().toString();
    }


    // ---
    // Item creation and binding
    // ---

    @Override
    public View onCreateView(UniReusableView container, String viewType)
    {
        ReusableItem.Type type = null;
        for (ReusableItem.Type checkType : ReusableItem.Type.values())
        {
            if (checkType.toString().equals(viewType))
            {
                type = checkType;
                break;
            }
        }
        if (type != null)
        {
            switch (type)
            {
                case Section:
                    container.getDividerView().setVisibility(View.GONE);
                    return new SectionView(container.getContext());
                case TopDivider:
                    container.getDividerView().setVisibility(View.GONE);
                    return new SectionDividerView(container.getContext(), false);
                case BottomDivider:
                    container.getDividerView().setVisibility(View.GONE);
                    return new SectionDividerView(container.getContext(), true);
                case Item:
                    return new ItemView(container.getContext());
            }
        }
        return null;
    }

    @Override
    public void onUpdateView(UniReusableView container, View view, String viewType, int itemPosition)
    {
        ReusableItem item = items.get(itemPosition);
        ReusableItem nextItem = null;
        if (itemPosition + 1 < items.size())
        {
            nextItem = items.get(itemPosition + 1);
        }
        switch (item.getType())
        {
            case Section:
                ((SectionView)view).setText(item.getTitle());
                break;
            case Item:
                ((ItemView)view).setTitle(item.getTitle());
                ((ItemView)view).setAdditional(item.getAdditional());
                ((ItemView)view).setValue(item.getValue());
                container.getDividerView().setVisibility(nextItem == null || nextItem.getType() != ReusableItem.Type.Item ? View.GONE : View.VISIBLE);
                break;
        }
    }

    @Override
    public View onCreateUnderView(UniReusableView container, String viewType)
    {
        ReusableItem.Type type = null;
        for (ReusableItem.Type checkType : ReusableItem.Type.values())
        {
            if (checkType.toString().equals(viewType))
            {
                type = checkType;
                break;
            }
        }
        if (type != null && type == ReusableItem.Type.Item)
        {
            UnderItemView underView = new UnderItemView(container.getContext());
            underView.setTitle(container.getContext().getString(R.string.hidden_view_title));
            underView.setAdditional(container.getContext().getString(R.string.hidden_view_text));
            return underView;
        }
        return null;
    }
}
